require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:michael)
    remember(@user)
  end

  # 短期セッションが nil の場合、永続セッションでログインしているユーザーを返すか
  test 'current_user returns right user when session is nil' do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  # 短期セッションが nil で、永続セッションが記憶トークンと一致しない場合、current_user が nil を返すか
  test 'current_user returns nil when remember digest is wrong' do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
