class User < ApplicationRecord
  # accessor
  # accessor として model 定義内で追加すると、仮想的な属性として扱える。
  # 仮想的な属性とは、インスタンスから呼び出せるが、データベースには保存されない属性のこと。
  attr_accessor :remember_token

  # 保存前に email を小文字に変換する
  # before_save { self.email = email.downcase } と等価
  before_save { email.downcase! }

  validates :name,
            presence: true,
            length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX },
            uniqueness: true

  has_secure_password
  validates :password,
            presence: true,
            length: { minimum: 8 },
            allow_nil: true

  # 永続的セッションのためにユーザーをデータベースに記憶する
  def remember
    # new_token メソッドで remember_token 仮想属性に Base64 の文字列を設定
    self.remember_token = User.new_token
    # digest メソッドで remember_digest カラムに remember_token をハッシュ化して保存
    update_attribute(:remember_digest, User.digest(remember_token))
    # ↑で DB に保存した remember_digest を返す
    remember_digest
  end

  # セッションハイジャック防止のためセッショントークンを返す
  # セッショントークンとして、remember_digest を使用
  def session_token
    # remember_digest が nil の場合、新しい remember メソッドで remember_digest を生成して返す
    remember_digest || remember
  end

  # 渡されたトークンがダイジェストと一致したら true を返す
  def authenticated?(remember_token)
    # 別ブラウザでログアウトした場合、remember_digest カラムの値は nil になる。
    # nil の場合、二行目でエラーになるので、false を返して早期脱出。
    return false if remember_digest.nil?

    # bcrypt内部の詳細は不明だが、
    # .is_password? で内部的に remember_token をハッシュ化して比較しているらしい。
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  class << self
    # 文字列を bcrypt ハッシュに変換
    def digest(string)
      const = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: const)
    end

    # ランダムなトークンを返す
    def new_token
      SecureRandom.urlsafe_base64 # "Li5i4FoDKHpRi8K3_Rbupw" など
    end
  end
end

# memo 1:
# - `validates :name, presence: true` = `validates(:name, { presence: true })`
# - `presence: true` は、`name` が空文字列でないことを検証する。全角スペースにも有効。

# memo 2:
# `User` -> `ApplicationRecord` -> `ActiveRecord::Base` の継承関係
# `Application::Base` で Active Record の主要な機能が提供されている。
# 一般に、`A::B` という構文は `A` クラスまたはモジュールの中で定義されている `B` という名前空間を指す。
# なお、Ruby で名前空間はクラスやモジュールによって形成される。
#
# `ApplicationRecord` がクラス、`ActiveRecord` がモジュール、`Base` がクラスであるので、
# `ApplicationRecord < ActiveRecord::Base` という構文は、
# 「`ApplicationRecord` クラスが、`ActiveRecord` モジュール内で定義されている `Base` クラスを参照・継承している」
# ことを示している。

# memo 3: メールアドレスの正規表現
# - `/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i` は、実務でもよく使われるメールアドレスの正規表現。
# RFC 5322などの公式の仕様は厳格ゆえ寛容すぎて、開発上向かず、実際のwebサービスと乖離している。
# 公式では例えば、""とスペースを含むものも許可されてしまう。
# 一つには、これは多くのサービスで無効なメールアドレスとして扱われるため、
# そのため、他サービスとの連携で問題が起きる可能性がある。
# また、""などは開発上、分岐して特別にエスケープ処理をするなどの対応も必要で、ミスにつながりやすくなるなどの問題もある。
#
# この正規表現の挙動は、[Rubular](https://rubular.com/r/tiSwfiusbOYkno) で確認できる。

# memo 4: `has_secure_password` メソッド
# - `has_secure_password` は、ActiveModel::SecurePassword モジュールに定義されているメソッド。
# - パスワードをハッシュ化してデータベースに保存する機能を提供する。
# - デフォルトで、`bcrypt` gem を使ってパスワードをハッシュ化する。
# 使用するには、二つの準備が必要。
# 1. `bcrypt` gem を インストール
# 2. パスワード を持たせたいモデルに `password_digest` カラムを追加。
# これらの準備が整ったら、`has_secure_password` を呼び出すだけで、
# 以下のような機能が使えるようになる。
# 1. 仮想属性 `password`, `password_confirmation`
#    - 存在性のバリデーションが（初めから強制的に）付与された、
#     `password` と `password_confirmation` という "仮想的な属性" が使えるようになる。
#    - なお、password_confirmation は、「確認のため、もう一度入力してください」という確認用パスワードのための属性。
#    - 「仮想的」というのは、これらは実際には DB に保存しないから。
#    - また、デフォルトで付与されている存在性のバリデーションは、
#      空文字のみを許容してしまうので、別途、`validates :password, presence: true` が必要。
# 2. パスワードのハッシュ化
#    1 の仮想的な属性には、本物のパスワードが格納されるが、これを DB に保存するのはセキュリティ上問題がある。
#    `has_secure_password` は代わりに、ハッシュ化したパスワードを `password_digest` カラムに保存することで、
#    この問題を解決する。
# 3. `authenticate` メソッド
#    ユーザーが入力したパスワードをハッシュ化して、
#    データベースに保存されているハッシュ化されたパスワードと比較し、`false` またはユーザーオブジェクトを返す。

# memo 5: ハッシュ化
# - ハッシュ化は、元のデータを「ハッシュ関数」と呼ばれるアルゴリズムによって、
#   "ロジカルに復元することが困難な" 一定長の文字列に変換すること。
#   ロジカルに復元困難というだけで、同じ入力に対しては常に同じハッシュ値が返るので、
#   組み合わせを知っているものは復元可能。
#   この脆弱性をついたレインボーテーブル攻撃などがある。
#   なお、`bcrypt` の場合には、ハッシュ化の際にランダムな「ソルト」と呼ばれる文字列を生成し、
#   それをパスワードに結合してからハッシュ化することで、レインボーテーブル攻撃を防いでいる。

# memo 6: `SecureRandom`
# `SecureRandom` は、rails 組み込みの乱数生成ライブラリ。
#
# `SecureRandom.urlsafe_base64(n, padding = true/false)`
# - URL に使える安全な（URLセーフな）ランダムな `Base64` 文字列を生成する。
# - このメソッドは、（引数 `n` でバイト数の指定がない場合）デフォルトで 22 文字の文字列を生成する。
# - `padding` が `true` の場合、`=` でパディングされた文字列を生成する。
# - 生成される文字列は、`A-Z`(26), `a-z`(26), `0-9`(10), `-`(1), `_`(1) のいずれかの文字(計64通り)で構成される。
#
# `SecureRandom.hex(n)`
# - `n` バイトのランダムな16進数文字列を生成する。
#
# `SecureRandom.uuid`
# - UUID (Universally Unique Identifier) を生成する。
#
# `SecureRandom.random_number(n)`
# - 0 から `n` までのランダムな整数を生成する。

# memo 7: `class << self` ブロック
# - `class << self` は、クラスメソッドを定義するための構文。
# `def Class.method` または `def self.method` における、
# `Class` や `self` をこのブロックでラップしていると省略できる。

# memo 8: `password` のバリデーションにおける `allow_nil: true`
# `update` 時の `PATCH` リクエスト時に (`name` や `email` のみの編集を意図しており)
# `password` が未入力でもリクエストを許容したいため。
# 新規ユーザー登録時には、`validates` メソッドによるバリデーションだけでなく、
# `has_secure_password` メソッドによるバリデーションが効くので、
# `validates` メソッドによるバリデーションで `nil` を許容して問題ない。
