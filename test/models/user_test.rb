require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: 'Example User', email: 'user@example.com')
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

  # 指定した email は有効なフォーマットとして認識されるべき
  test 'email validation should accept valid addresses' do
    valid_addresses = %w[
      user@example.com
      USER@foo.COM
      A_US-ER@foo.bar.org
      first.last@foo.jp
      alice+bob@baz.cn
    ]

    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # 指定した email は無効なフォーマットとして認識されるべき
  test 'email validation should be rejected invalid addresses' do
    invalid_addresses = [
      'user@example,com',   # コンマは許可されていない
      'user_at_foo.org',    # @ がない
      'user.name@example.', # ドメインがない
      'foo@bar_baz.com',    # ドメイン名のアンダースコアは許可されていない
      'foo@bar+baz.com',    # ドメイン名のプラスは許可されていない
      'foo@bar..com'        # ドメイン名のドットが連続している
    ]

    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
end

# memo:
# - `assert` メソッドの第二引数には、エラーメッセージを指定できる。
