require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  # ※ メールの送信のテストというよりメールの内容のテスト
  test 'account_activation' do
    # テストユーザーを取得
    user = users(:michael)
    # 有効化トークンを生成
    user.activation_token = User.new_token

    # メールを作成
    mail = UserMailer.account_activation(user)

    # メールを検証
    # 設定
    assert_equal 'Account activation',        mail.subject      # 件名
    assert_equal [user.email],                mail.to           # 宛先
    assert_equal ['koichiro.mika@gmail.com'], mail.from         # 送信元
    # 本文
    assert_match user.name,                   mail.body.encoded # テストユーザーの名前
    assert_match user.activation_token,       mail.body.encoded # 有効化トークン
    assert_match CGI.escape(user.email),      mail.body.encoded # メールアドレス
  end

  # password_reset は未実装のためコメントアウト
  # test 'password_reset' do
  #   mail = UserMailer.password_reset
  #   assert_equal 'Password reset',     mail.subject
  #   assert_equal ['to@example.org'],   mail.to
  #   assert_equal ['from@example.com'], mail.from
  #   assert_match 'Hi',                 mail.body.encoded
  # end
end

# memo 1: `assert_match`
# 正規表現を使ってメールの本文を検証できる
# assert_match 'foo', 'foobar'      # true
# assert_match 'baz', 'foobar'      # false
# assert_match /\w+/, 'foobar'      # true
# assert_match /\w+/, '$#!*+@'      # false
