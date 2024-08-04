require 'test_helper'

class UsersSignup < ActionDispatch::IntegrationTest
  # テスト実行前にメール配信をクリア
  # メールは作成されると、グローバルな deliveries 配列に追加される
  # テスト間でメールが共有されることで不具合が生じないように、テスト実行前にクリアする
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup
  # 無効なユーザーデータではサインアップできてはならない
  test 'invalid signup information' do
    # 省略可能だが、実際のユーザーの手順通りにまずは '/signup' にアクセスする
    get signup_path
    # ブロックの処理前後で User.count が変わらない（ユーザーが追加されない）ことを確認
    assert_no_difference 'User.count' do
      # 無効な 'params' でPOSTリクエストを送信
      post users_path, params: {
        user: {
          name: '',
          email: 'user@invalid',
          password: 'foo',
          password_confirmation: 'bar'
        }
      }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'

    # エラーメッセージが表示されていることを確認
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  # 有効なユーザーデータではサインアップできるべき
  # 適切な POST リクエストに応答して、メールが配信キューに追加されることを確認
  test 'valid signup information with account activation' do
    get signup_path
    # ブロックの処理前後で User.count が 1 増えることを確認
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: 'Example Taro',
          email: 'taro@example.com',
          password: 'tutorial',
          password_confirmation: 'tutorial'
        }
      }

      # メールが配信キューに追加されたことを確認
      assert_equal 1, ActionMailer::Base.deliveries.size
    end
  end
end

class AccountActivationTest < UsersSignup
  def setup
    super
    post users_path, params: {
      user: {
        name: 'Example Taro',
        email: 'taro@example.com',
        password: 'tutorial',
        password_confirmation: 'tutorial'
      }
    }
    @user = assigns(:user)
  end

  # setup で POST リクエストが送信されただけではアカウントが有効化されていないことを確認
  test 'should not be activated' do
    assert_not @user.activated?
  end

  # GET リクエストで有効化される前にログインを試みても失敗することを確認
  test 'should not be able to log in before account activation' do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  # 無効なトークンのリンクで有効化できないことを確認
  test 'should not be able to log in with invalid activation token' do
    invalid_token = 'invalid token'
    get edit_account_activation_path(invalid_token, email: @user.email)
    assert_not is_logged_in?
  end

  # 無効なメールのリンクで有効化できないことを確認
  test 'should not be able to log in with invalid email' do
    invalid_email = 'wrong'
    get edit_account_activation_path(@user.activation_token, email: invalid_email)
    assert_not is_logged_in?
  end

  # 有効なトークンとメールでログインできることを確認
  test 'should log in successfully with valid activation token and email' do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
