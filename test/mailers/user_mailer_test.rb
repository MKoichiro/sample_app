require 'test_helper'

class UserMailers < ActionMailer::TestCase
  def setup
    # テストユーザーを取得
    @user = users(:michael)
    # 送信元のメールアドレス
    @email_from = 'koichiro.mika@gmail.com'
  end
end

# ※ メールの送受信のテストというよりメールの内容のテスト
class UserMailerTest < UserMailers
  # アカウント有効化のメールの内容に関するテスト
  test 'account_activation' do
    # 有効化トークンを生成
    @user.activation_token = User.new_token

    # メールを作成
    mail = UserMailer.account_activation(@user)

    # メールを検証
    # 設定
    assert_equal 'Account activation',  mail.subject      # 件名
    assert_equal [@user.email],         mail.to           # 宛先
    assert_equal [@email_from],         mail.from         # 送信元
    # 本文
    body = mail.body.encoded
    assert_match @user.name,              body # テストユーザーの名前
    assert_match @user.activation_token,  body # 有効化トークン
    assert_match CGI.escape(@user.email), body # メールアドレス
  end

  # パスワード再設定のメールの内容に関するテスト
  test 'password_reset' do
    @user.reset_token = User.new_token
    mail = UserMailer.password_reset(@user)

    assert_equal 'Password reset', mail.subject
    assert_equal [@user.email],    mail.to
    assert_equal [@email_from],    mail.from

    body = mail.body.encoded
    assert_match @user.reset_token,       body
    assert_match CGI.escape(@user.email), body
  end
end

# memo 1: `assert_match`
# 正規表現を使ってメールの本文を検証できる
# assert_match 'foo', 'foobar'      # true
# assert_match 'baz', 'foobar'      # false
# assert_match /\w+/, 'foobar'      # true
# assert_match /\w+/, '$#!*+@'      # false
