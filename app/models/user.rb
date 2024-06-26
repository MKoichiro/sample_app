class User < ApplicationRecord
  validates :name,
            presence: true,
            length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email,
            presence: true,
            length: { maximum: 255 },
            format: { with: VALID_EMAIL_REGEX }
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
