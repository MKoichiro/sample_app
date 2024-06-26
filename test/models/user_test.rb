require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user.example.com')
  end

  # user は有効でなければならない
  test 'should be valid' do
    assert @user.valid?
  end

  # name は空文字列であってはならない
  test 'name should be present' do
    @user.name = '     '
    assert_not @user.valid?
  end

  # email は空文字列であってはならない
  test 'email should be present' do
    @user.email = '     '
    assert_not @user.valid?
  end

  # name は 50 文字以下であるべき（50に特別な意味はないが、view表示時に扱いやすい数値にする）
  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  # email は 255 文字以下であるべき（多くのDBMSでstring型の最大長が255文字）
  test 'email should not be too long' do
    @user.email = "#{'a' * 244}@example.com"
    assert_not @user.valid?
  end
end
