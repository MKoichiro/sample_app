require 'test_helper'

class UsersLogin < ActionDispatch::IntegrationTest
  def setup
    # `users` メソッドは `fixtures/users.yml` があると自動生成され、
    # `fixtures/users.yml` に定義したテスト用データを参照できる
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin
  # ログインページにアクセスできるか
  test 'login path' do
    get login_path
    assert_template 'sessions/new'
  end

  # 間違ったパスワードでログインできないか
  test 'login with valid email/invalid password' do
    post login_path, params: { session: { email: @user.email, password: 'invalid' } } # 正しいパスワードは "password"
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?

    # 別ページに移動したときにフラッシュメッセージが消えることを確認
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLogin
  def setup
    super
    post login_path, params: { session: { email: @user.email, password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin
  # ログインしてユーザーページにリダイレクトされるか
  test 'valid login' do
    assert is_logged_in?
    assert_redirected_to @user
  end

  # リダイレクト先のユーザーページにログアウトボタンがあり、ログインボタンなどがないことを確認
  test 'redirect after login' do
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0 # ログインボタンが表示されていないことを確認
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user) # プロフィールページへのリンクが表示されていることを確認
  end
end

class Logout < ValidLogin
  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout
  # ログアウトしてルートページにリダイレクトされるか
  test 'successful logout' do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_path
  end

  # リダイレクト先のルートページにログインボタンがあり、ログアウトボタンなどがないことを確認
  test 'redirect after logout' do
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  # Logout クラスで一度目の logout した後、
  # 別 window から再度 logout した場合、logout 処理をスキップし、
  # 単に root_url にリダイレクトするか
  test 'should still work after logout in 2nd window' do
    delete logout_path
    assert_redirected_to root_url
  end
end
