require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @admin = users(:michael)
    @non_admin = users(:archer)
  end

  # test 'index including pagination' do
  #   log_in_as(@user)
  #   get users_path
  #   assert_template 'users/index'

  #   # ページネーションのリンクは 2 個（上下）にあるべき
  #   assert_select 'div.pagination', count: 2
  #   # ユーザーに紐づいたリンクが表示されているべき
  #   User.paginate(page: 1).each do |user|
  #     assert_select 'a[href=?]', user_path(user), text: user.name
  #   end
  # end

  # 管理者の場合、index ページにリンクが表示されていること、
  # かつ、自身以外のユーザーには削除リンクが表示されること、
  # かつ、削除リンクをクリックするとユーザーが削除されることをテスト
  test 'index as admin including pagination and delete links' do
    first_page_of_users = User.paginate(page: 1)

    log_in_as(@admin)
    get users_path
    assert_template 'users/index'

    # ページネーションのリンクは 2 個（上下）にあるべき
    assert_select 'div.pagination', count: 2
    # ユーザーに紐づいたリンクが表示されているべき
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end

    # 一般ユーザーを削除すると、ユーザー数が 1 減るべき
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_response :see_other
      assert_redirected_to users_url
    end
  end

  # 一般ユーザーの場合、削除リンクが表示されていないことを確認
  test 'index as non-admin' do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
