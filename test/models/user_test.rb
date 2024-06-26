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
end
