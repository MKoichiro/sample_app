require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  # setup は特殊なキーワード
  # テストフレームワーク minitest において、各テストメソッドが実行される直前に実行される特別なメソッドになる。
  def setup
  end

  test 'should get home' do
    get root_path
    assert_response :success
    assert_select 'title', full_title
  end

  test 'should get help' do # 「help ページのテスト」
    # TEST 1
    get help_path            # 「"/help" の URL に HTTP GET リクエストを送信してください。」
    assert_response :success # 「そのレスポンスは成功（HTTP ステータスコード 2XX）であるべきです。」

    # TEST 2
    assert_select 'title', full_title('Help') # 「title タグの中身は「Home | Ruby on Rails Tutorial Sample App」であるべきです。」
  end

  test 'should get about' do
    get about_path
    assert_response :success
    assert_select 'title', full_title('About')
  end

  test 'should get contact' do
    get contact_path
    assert_response :success
    assert_select 'title', full_title('Contact')
  end
end
