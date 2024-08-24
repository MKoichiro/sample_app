require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael) # 管理者ユーザー
    @other_user = users(:archer) # 一般ユーザー
  end

  test 'should get new' do
    get signup_path
    assert_response :success
  end

  test 'should redirect index when not logged in' do
    get users_path
    assert_redirected_to login_url
  end

  # "edit" action のテスト
  # ログインしていないユーザーが編集ページへアクセスを試みた場合、
  # エラーを表示してログインページにリダイレクトするべき
  test 'should redirect edit when not logged in' do
    # ログインせずにeditページにアクセス
    get edit_user_path(@user)

    # エラーメッセージを表示してログインページにリダイレクト
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # "update" action のテスト
  # ログインしていないユーザーが更新を試みた場合、
  # エラーを表示してログインページにリダイレクトするべき
  test 'should redirect update when not logged in' do
    # ログインせずに有効なパラメータで更新を試みる
    patch user_path(@user), params: {
      user: {
        name: @user.name,
        email: @user.email
      }
    }

    # エラーメッセージを表示してログインページにリダイレクト
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # "edit" action のテスト
  # 間違ったユーザーが他のユーザーの編集ページへアクセスを試みた場合、
  # エラーを表示してホームページにリダイレクトするべき
  test 'should redirect edit when logged in as wrong user' do
    # archer でログインして、michael の edit ページにアクセス
    log_in_as(@other_user)
    get edit_user_path(@user)

    # メッセージは表示せず、ホームページにリダイレクト
    assert flash.empty?
    assert_redirected_to root_url
  end

  # "update" action のテスト
  # 間違ったユーザーが他のユーザーの更新を試みた場合、
  # エラーを表示してホームページにリダイレクトするべき
  test 'should redirect update when logged in as wrong user' do
    # archer でログインして、michael の patch リクエストを送信して更新を試みる
    log_in_as(@other_user)
    patch user_path(@user), params: {
      user: {
        name: @user.name,
        email: @user.email
      }
    }

    # メッセージは表示せず、ホームページにリダイレクト
    assert flash.empty?
    assert_redirected_to root_url
  end

  # PATCH リクエストを送信して、管理者属性を変更できないことを確認
  test 'should not allow the admin attribute to be edited via the web' do
    log_in_as(@other_user)
    assert_not @other_user.admin?
    patch user_path(@other_user), params: {
      user: {
        password: 'password',
        password_confirmation: 'password',
        admin: true
      }
    }

    # strong parameters で admin 属性を許可していないため、変更されないはず
    assert_not @other_user.reload.admin?
  end

  # ログインしていなければ、管理者であるかに関係なく、削除できず、ログインページにリダイレクトすることを確認
  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete user_path(@other_user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  # ログインしていても、管理者でなければ削除できず、ホームページにリダイレクトすることを確認
  test 'should redirect destroy when logged in as a non-admin' do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end

  test 'should redirect following when not logged in' do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test 'should redirect followers when not logged in' do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
