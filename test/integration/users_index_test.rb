require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'index including pagination' do
    log_in_as(@user)
    get users_path
    assert_template 'users/index'

    # ページネーションのリンクは 2 個（上下）にあるべき
    assert_select 'div.pagination', count: 2
    # ユーザーに紐づいたリンクが表示されているべき
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
