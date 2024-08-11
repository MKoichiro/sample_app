require 'test_helper'

class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
    @invalid_email = 'invalid'
  end
end

class ForgotPasswordFormTest < PasswordResets
  test 'password reset path' do
    # view の表示確認のみ、new action に処理は無い
    get new_password_reset_path
    assert_template 'password_resets/new'
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  # 失敗パターン
  test 'reset path with invalid email' do
    # create action のテスト
    post password_resets_path, params: { password_reset: { email: @invalid_email } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_template 'password_resets/new'
  end

  # 成功パターンは、PasswordResetForm 以下でテスト
end

class PasswordResetForm < PasswordResets
  def setup
    super
    post password_resets_path, params: { password_reset: { email: @user.email } }

    # 直前のcontorollerのactionで生成された@userを取得
    # この場合、create action で生成された@userを取得
    @reset_user = assigns(:user)
  end
end

class PasswordFormTest < PasswordResetForm
  test 'reset with valid email' do
    # assert_not_equal @user.reset_digest, @reset_user.reset_digest # rails tutorial のやり方。納得いかないので下記に変更。
    assert_nil @user.reset_digest
    assert_not_nil @reset_user.reset_digest

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test 'reset with wrong email' do
    wrong_email = 'wrong_' + @reset_user.email
    get edit_password_reset_path(@reset_user.reset_token, email: wrong_email)
    assert_redirected_to root_url
  end

  test 'reset with inactive user' do
    # デアクティベート
    @reset_user.toggle!(:activated)

    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_redirected_to root_url

    # 今後のテストのために、再度アクティベートしておく
    @reset_user.toggle!(:activated) # rails tutorial には無いがそのままでは気持ちがわるいので、絶対に合った方がいい、と思う。
  end

  test 'reset with right email but wrong token' do
    get edit_password_reset_path('wrong_token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test 'reset with right email and right token' do
    get edit_password_reset_path(@reset_user.reset_token, email: @reset_user.email)
    assert_template 'password_resets/edit'
    assert_select 'input[name=email][type=hidden][value=?]', @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm
  test 'update with invalid password and confirmation' do
    patch password_reset_path(@reset_user.reset_token),
          params: {
            email: @reset_user.email,
            user: {
              password: 'foobaz',
              password_confirmation: 'barquux'
            }
          }
    assert_select 'div#error_explanation'
  end

  test 'update with empty password' do
    patch password_reset_path(@reset_user.reset_token),
          params: {
            email: @reset_user.email,
            user: {
              password: '',
              password_confirmation: ''
            }
          }
    assert_select 'div#error_explanation'
  end

  test 'update with valid password and confirmation' do
    patch password_reset_path(@reset_user.reset_token),
          params: {
            email: @reset_user.email,
            user: {
              password: 'password',
              password_confirmation: 'password',
            }
          }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user

    # 再設定後は、2時間の有効期限切れを待たずに、reset_digest を nil になるべき
    assert_nil @reset_user.reload.reset_digest
  end
end

class ExpiredToken < PasswordResetForm
  def setup
    super

    # reset_token を手動で期限切れにする
    @reset_user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(@reset_user.reset_token),
          params: {
            email: @reset_user.email,
            user: {
              password: 'password',
              password_confirmation: 'password'
            }
          }
  end
end

class ExpiredTokenTest < ExpiredToken
  test 'should reditect to the password-reset page' do
    assert_redirected_to new_password_reset_url
  end

  test "should include the word 'expired' on the password-reset page" do
    follow_redirect!

    # response.body は、ページの HTML の全文を返す
    assert_match /expired/i, response.body
  end
end