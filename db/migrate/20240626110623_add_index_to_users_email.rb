class AddIndexToUsersEmail < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :email, unique: true
  end
end

# memo 1:
# `rails db:migrate` でタイムスタンプ順に `db/migrate` 配下のマイグレーションファイルが実行される。
# [timestamp]_add_index_to_users_email.rb での `add_index` メソッドの処理は、
# rails tutorialの流れ上あとから、`rails g migration add_index_to_users_email` コマンドで生成したため、
# [timestamp]_create_users.rb と分けられているが、
# 本来は `CreateUsers` の `create_table` の直後に追加しても正常に動作する。

# memo 2:
# - `add_index(table, column, unique: true)` メソッドは、table の column に index を追加するためのメソッド。
# - `unique: true` は、そのカラムに一意性制約を設定するためのオプション。
# - ここでの指定は、`user.rb` の `validates :email, uniqueness: true` による一意性制約とは別物である。
#   ここでは、データベースレベルでの一意性制約を設定しており、
#   `user.rb` での指定は、アプリケーションレベルでの一意性制約である。
#   例えば、素早く2回クリックするなどで、POST リクエストがほぼ同時に送信された場合、
#   アプリケーションレベルの validation をくぐり抜けてしまう可能性がある。
# - データベースにおける index は、データベースの検索速度を向上させるためのもの。
# - 一意性とインデックス
#   一見互いに独立した概念に見えるが、
#   「一意性を保証するためには、データ追加時に全件検索が必要であり、その全件検索の高速化に index が必要である」ということである。
