# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# 管理者権限を持つサンプルユーザーを1人作成する
User.create!(
  name: 'Example User',
  email: 'example@railstutorial.org',
  password: 'foobarbaz',
  password_confirmation: 'foobarbaz',
  admin: true,
  activated: true,
  activated_at: Time.zone.now
)

# 追加のサンプルユーザーをまとめて生成する
99.times do |n|
  name = Faker::Name.name # => "Christophe Bartell" (facker gem でランダムな名前を生成)
  email = "example-#{n + 1}@railstutorial.org"
  password = 'password'

  User.create!(
    name:,
    email:,
    password:,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now
  )
end

# memo 1: `create!`
# `create!` は `create` と違い、データが無効の場合に「例外」（エラー）を発生させる。
