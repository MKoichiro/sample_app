require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  # setupは特殊なキーワード。
  # テストフレームワークminitestにおいて、各テストメソッドが実行される直前に実行される特別なメソッドになる。
  def setup
    @base_title = 'Ruby on Rails Tutorial Sample App'
  end

  test 'should get home' do # 「homeページのテスト」
    get root_path # static_pages/home のURLにHTTP GETリクエストを送信します。
    # このリクエストは、static_pagesコントローラのhomeアクションを呼び出します。
    assert_response :success # その結果のレスポンスは成功（例: HTTPステータスコード200）であるべきです。
    assert_select 'title', @base_title # titleタグの中身が「Home | Ruby on Rails Tutorial Sample App」であることを確認します。
  end

  test 'should get help' do
    get help_path
    assert_response :success
    assert_select 'title', "Help | #{@base_title}"
  end

  test 'should get about' do
    get about_path
    assert_response :success
    assert_select 'title', "About | #{@base_title}"
  end

  test 'should get contact' do
    get contact_path
    assert_response :success
    assert_select 'title', "Contact | #{@base_title}"
  end
end
