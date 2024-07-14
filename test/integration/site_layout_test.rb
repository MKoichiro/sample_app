require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'layout links' do
    get root_path
    assert_template 'static_pages/home'

    assert_select 'a[href=?]', root_path, count: 2
    assert_select 'a[href=?]', help_path
    assert_select 'a[href=?]', about_path
    assert_select 'a[href=?]', contact_path
    assert_select 'a[href=?]', signup_path

    log_in_as(@user)
    get users_path
    assert_template 'users/index'
    assert_select 'a[href=?]', user_path(@user)
    assert_select 'a[href=?]', user_path(@other_user)
  end
end
