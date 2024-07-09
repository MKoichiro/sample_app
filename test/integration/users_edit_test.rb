require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'unsuccessful edit' do
    log_in_as(@user) # before filter でログインチェックが行われるため、ログインしている必要がある。
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: {
      user: {
        name: '',
        email: 'foo@invalid',
        password: 'foo',
        password_confirmation: 'bar'
      }
    }
    assert_template 'users/edit'
  end

  test 'successful edit with friendly forwarding' do
    # ログインしていない状態で編集ページにアクセス
    get edit_user_path(@user)
    # すると、セッションに URL が保存される
    assert_equal session[:forwarding_url], edit_user_url(@user)
    # ログインページにリダイレクトしてログイン
    log_in_as(@user)
    # ログイン後、編集ページに戻ることを確認 (friendly forwarding)
    assert_redirected_to edit_user_url(@user)
    # ログイン後にはセッションに保存していた URL が削除される
    assert_nil session[:forwarding_url]

    # name と email を変更する
    new_name = 'Foo Bar'
    new_email = 'foo@bar.com'

    # 新しい name と email で PATCH リクエストを送信する
    patch user_path(@user), params: {
      user: {
        name: new_name,
        email: new_email,
        password: '',
        password_confirmation: ''
      }
    }

    # 成功メッセージを表示して、ユーザーページにリダイレクトすることを確認
    assert_not flash.empty?
    assert_redirected_to @user

    # reload: データベースから最新の情報を取得する
    @user.reload
    # 変更の適用を確認
    assert_equal new_name, @user.name
    assert_equal new_email, @user.email
  end
end
