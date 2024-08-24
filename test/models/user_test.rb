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
      'user@example,com',   # コンマ
      'user_at_foo.org',    # @ がない
      'user.name@example.', # ドメインがない
      'foo@bar_baz.com',    # ドメイン名のアンダースコア
      'foo@bar+baz.com',    # ドメイン名のプラス
      'foo@bar..com'        # ドメイン名のドットが連続
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

  # password は全て空文字列であってはならない（一部空文字は現状許可）
  test 'password should be present (nonblank)' do
    @user.password = @user.password_confirmation = ' ' * 8
    assert_not @user.valid?
  end

  # password は 8 文字以上であるべき
  test 'password should have a minimum length' do
    @user.password = @user.password_confirmation = 'a' * 7
    assert_not @user.valid?
  end

  # remember_digest カラムが nil なら、authenticated? は false を返すべき
  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?(:remember, '')
  end

  # ユーザーが削除されたら、従属する microposts も削除されるべき
  test 'associated microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'Lorem ipsum')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    michael = users(:michael)
    archer = users(:archer)

    assert_not michael.following?(archer)

    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)

    michael.unfollow(archer)
    assert_not michael.following?(archer)

    # 自身をフォローできない
    michael.follow(michael)
    assert_not michael.following?(michael)
  end

  test 'feed should have the right posts' do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # michael が、lana をフォローしているが、archer はフォローしていない

    # フォローしているユーザーの投稿を確認
    # michael のフィードに、lanaの投稿が含まれるべき
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end

    # 自分自身の投稿を確認
    # michael のフィードに、自分自身の投稿が含まれるべき
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end

    # フォローしていないユーザーの投稿を確認
    # michael のフィードに、archer の投稿が含まれていてはならない
    archer.microposts.each do |post_unfollow|
      assert_not michael.feed.include?(post_unfollow)
    end
  end
end

# memo:
# - `assert` メソッドの第二引数には、エラーメッセージを指定できる。
# - test 環境では他環境とは独立したデータベースを作成する。
#   またテスト中にデータベースに加えた変更はテスト完了後に都度、自動で破棄される。
