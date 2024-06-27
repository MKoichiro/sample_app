require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # テスト環境で使うユーザーを作成
  def setup
    @user = User.new(
      name: 'Example User',
      email: 'user@example.com',
      password: 'password',
      password_confirmation: 'password'
    )
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

  # email は一意であるべき
  test 'email addresses should be unique' do
    duplicate_user = @user.dup       # copy を作成
    @user.save                       # original を保存
    assert_not duplicate_user.valid? # original がすでにあるとき、copy は無効
  end

  # email は保存の直前に小文字に変換されるべき
  test 'email addresses should be saved as lower-case' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # password は全て空文字列であってはならない
  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 8
    assert_not @user.valid?
  end

  # password は 8 文字以上であるべき
  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 7
    assert_not @user.valid?
  end
end

# memo:
# - `assert` メソッドの第二引数には、エラーメッセージを指定できる。
# - test 環境では他環境とは独立したデータベースを作成する。
#   またテスト中にデータベースに加えた変更はテスト完了後に都度破棄される。
