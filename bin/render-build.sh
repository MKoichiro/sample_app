#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
# bundle exec rails db:migrate
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rails db:migrate:reset

# 事前に用意したサンプルユーザーをデータベースに追加
bundle exec rails db:seed


# memo 1: `DISABLE_DATABASE_ENVIRONMENT_CHECK=1`
# Railsのデータベース操作に関する安全チェックを無効化し、
# デプロイ時にデータベースのリセット(`bundle exec rails db:migrate:reset`)を可能に。