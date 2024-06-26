class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true
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
