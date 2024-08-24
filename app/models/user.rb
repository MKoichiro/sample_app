class User < ApplicationRecord
  # - アソシエーション

  # user.microposts で、micropost model から、user_id と一致する micropost を自動的に取得する仕様。
  # これは、symbolが :microposts で、class_name が 'Micropost' であり、自身のクラス名が User であるから可能。
  has_many :microposts, dependent: :destroy

  # フォロー機能のアソシエーション
  # User table の内部 id と、Relationship table の follower_id, followed_id を外部 id として紐づけ
  # User.active/passive_relationships で、follower/followed の Relationships オブジェクトが取得可能に
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships # source: :follower は省略可能。Rails が自動的に、:follower_id を参照

  # - accessor
  # accessor として model 定義内で追加すると、仮想的な属性として扱える。
  # 仮想的な属性とは、インスタンスから呼び出せるが、データベースには保存されない属性のこと。
  # オブジェクトとは紐づけるが、データベースには保存すべきではない各種トークンなどが該当。

  attr_accessor :remember_token, :activation_token, :reset_token


  # - before_メソッド

  # 保存前に email を小文字に変換する
  # before_save { self.email = email.downcase } と等価
  # before_save { email.downcase! }
  before_save :downcase_email

  # User オブジェクトの生成前に、有効化トークンとダイジェストを作成する
  before_create :create_activation_digest


  # - バリデーション

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


  # - メソッド

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
  # def authenticated?(remember_token)
  #   # 別ブラウザでログアウトした場合、remember_digest カラムの値は nil になる。
  #   # nil の場合、二行目でエラーになるので、false を返して早期脱出。
  #   return false if remember_digest.nil?

  #   # bcrypt 内部の詳細は不明だが、
  #   # .is_password? で内部的に remember_token をハッシュ化して比較しているらしい。
  #   BCrypt::Password.new(remember_digest).is_password?(remember_token)
  # end

  # 11.3.1: authenticated? メソッドを汎用的(remember me, account activation)
  def authenticated?(attribute, token)
    # send メソッドで、remember_digest メソッド、または activation_digest メソッドを動的に呼び出す
    digest = send("#{attribute}_digest")
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password?(token)
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


  # ACCOUNT ACTIVATION
  # アカウント有効化の属性を設定
  def activate
    # update_attribute(:activated, true)
    # update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)

    # update_columns は、update_attributes と異なり、バリデーションやモデルコールバックをスキップするので、注意
  end

  # アカウント有効化用のメールを送信
  def send_activation_email
    # UserMailer.account_activation メソッドは、app/mailers/user_mailer.rb で定義
    UserMailer.account_activation(self).deliver_now
  end


  # RESET PASSWORD
  # パスワード再設定の属性を設定
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定用のメールを送信
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定リンクの期限切れを判定。(2時間)
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  # ユーザーのフィード(タイムライン、投稿一覧)を返す
  def feed
    # 案Ⅰ:
    # ```Micropost.where('user_id IN (?) OR user_id = ?', following_ids, id)```
    # 1. SQL クエリ
    # ```SELECT * FROM microposts WHERE user_id IN (1, 2, 3) OR user_id = 1```
    # 2. `following_ids` メソッド
    # - `following_ids` は、`has_many through` のアソシエーションを受けて、Rails が自動定義する。これは `following_id` の配列を返す。
    # - 実際は、`<user object>.following.map { |i| i.id }` の処理が行われる。
    # 3. 解説
    # Micropost table の `user_id` が、
    #   自身のフォローしているユーザーの `id` と一致するか (`IN <following_ids>`)、
    #   または、
    #   自身の `id` と一致する (`OR user_id = <id>`)
    # という条件で、micropost を取得する。
    # 4. 動作
    # - 正常
    # 5. 問題点
    # - フォローしているユーザーが大量にいる場合に問題になる。
    # - `following_ids` で、データベースから一度メモリに大量のデータを取得するため、非効率。

    # 案Ⅱ: サブクエリ
    # ```
    # following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    # Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
    # ```
    # 1. SQL クエリ
    # ```SELECT * FROM microposts WHERE user_id IN (SELECT followed_id FROM relationships WHERE follower_id = 1) OR user_id = 1```
    # 2. 解説
    # `following_ids` メソッドを使わずに、SQL のサブクエリを直接指定して使うことで、
    # ローカルのメモリを使うことなく、データベース側で効率的に処理する。
    # 3. 動作
    # - 正常
    # 4. 問題点
    # フィードパーシャルが、マイクロポストパーシャルを表示している。
    # マイクロポストのパーシャルが、対応するユーザーの情報を表示する時に、追加でクエリが発生する。
    # これは、マイクロポストがN個ある場合、"追加で" N 回のクエリが発生することを意味する。( N + 1 問題)
    # また、今回の場合、添付画像も取得するため、2N + 1 回のクエリが発生する。

    # 案Ⅲ: eager loading
    following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id).includes(:user, image_attachment: :blob)
  end

  # ユーザーをフォローする
  def follow(other_user)
    # active_relationships.create(followed_id: other_user.id) unless self == other_user
    # self.following 配列に other_user を追加
    following << other_user unless self == other_user
  end

  # ユーザーをアンフォローする
  def unfollow(other_user)
    # self.following 配列から other_user を削除
    following.delete(other_user)
  end

  # フォローチェック
  def following?(other_user)
    # self.following 配列に other_user が含まれているか検索
    # このとき rails はデータベース側で検索を行い、高効率になるように配慮している。
    following.include?(other_user)
  end

  # 被フォローチェック
  # def followed_by?(other_user)
  #  followers.include?(other_user)
  # end

  private

  def downcase_email
    # `self.email = email.downcase` と等価、破壊的メソッドなら代入は不要
    email.downcase!
  end

  def create_activation_digest
    # 有効化トークンとダイジェストを生成・代入
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
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

# memo 9: Micropost.where('user_id = ?', id)
# - where メソッドは、ActiveRecordの記法で、SQLクエリを生成する。
# - `?` はプレースホルダーで、SQLインジェクションを防ぐために使用される。
# 例えば、
# ```
# user_id = params[:id]
# Micropost.where("user_id = #{user_id}")
# ```
# とすると、悪意あるユーザーがhttps://example.com/users/microposts?user_id=1; DROP TABLE users
# などのように、SQLインジェクションを仕掛けることができる。
# これを防ぐために、プレースホルダー（?）を使用して、RailsにSQLクエリを安全に生成させる。