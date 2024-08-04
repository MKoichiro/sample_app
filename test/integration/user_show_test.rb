require 'test_helper'

class UserShowTest < ActionDispatch::IntegrationTest
  def setup
    # 有効化していない一般ユーザー
    @inactive = users(:inactive)
    # 有効化済みの一般ユーザー
    @active = users(:archer)
  end

  test 'should redirect when user not activated' do
    get user_path(@inactive)
    assert_response :redirect
    assert_redirected_to root_url
  end

  test 'should show user when activated' do
    get user_path(@active)
    assert_response :success
    assert_template 'users/show'
  end
end
