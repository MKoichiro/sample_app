class User < ApplicationRecord
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
  validates :password, presence: true, length: { minimum: 8 }

  # 文字列を bcrypt ハッシュに変換
  def self.digest(string)
    const = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: const)
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
