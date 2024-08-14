require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test 'profile display' do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'

    # assert_match @user.microposts.count.to_s, response.body
    # ↑rails tutorial の案。2, 3桁程度の自然数をbody全体から検索するのは、他の部分から誤検出する可能性がある。と思うので却下。
    # ↓代替案
    assert_select 'h3', text: /Microposts \(#{@user.microposts.count}\)/

    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
