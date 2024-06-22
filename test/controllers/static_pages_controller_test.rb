require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test 'should get home' do # 「homeページのテスト」
    get static_pages_home_url # static_pages/home のURLにHTTP GETリクエストを送信します。
    # このリクエストは、static_pagesコントローラのhomeアクションを呼び出します。
    assert_response :success # その結果のレスポンスは成功（例: HTTPステータスコード200）であるべきです。
  end

  test 'should get help' do
    # "static_pages_help_url"はテスト用のヘルパーメソッドであり、
    # routes.rbの内容に基づいて自動的に生成される。
    get static_pages_help_url
    assert_response :success
  end

  test 'should get about' do
    get static_pages_about_url
    assert_response :success
  end
end
