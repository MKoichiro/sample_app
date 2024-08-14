require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)

    # @micropost = Micropost.new(content: 'Lorem ipsum', user_id: @user.id)
    # と同じだが、以下が慣習的に正しい。
    @micropost = @user.microposts.build(content: 'Lorem ipsum')
  end

  test 'should be valid' do
    assert @micropost.valid?
  end

  # 「有効な micropost は、user_id を持つべき」ということをテストしている [memo 1]
  # 対偶を利用してテスト、以下同様の手法あり。
  test 'user id should be present' do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test 'content should be present' do
    @micropost.content = '   '
    assert_not @micropost.valid?
  end

  test 'content should be at most 140 characters' do
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end

  test 'order should be most recent first' do
    # microposts(:most_recent) は、test/fixtures/microposts.yml に定義されている
    assert_equal microposts(:most_recent), @user.microposts.first
  end
end

# memo 1: 対偶によるテスト
# @micropost.valid? の真偽は操作不可能のため、
# 「有効な micropost は、user_id を持つべき」ということをテストするには、
# 「micropost は有効である => user_id が存在する」
# の対偶を取って
# 「user_id が存在しない => micropost が無効である」
# を確認する。
