require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  # ログイン失敗時のテスト
  test 'login with invalid information' do
    get login_path
    assert_template 'sessions/new'
    # post invalid session information
    post login_path, params: { session: { email: '', password: '' } }
    assert_response :unprocessable_entity

    # re-rendered 'new' template
    assert_template 'sessions/new'
    # flash message is displayed
    assert_not flash.empty?

    # access root_path
    get root_path
    # flash message is not displayed
    assert flash.empty?
  end
end
