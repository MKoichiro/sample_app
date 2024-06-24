require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  # Unit test for the full_title helper
  test 'full_title helper' do
    # `assert_equal <expected>, <actual>`
    # 内部的には単に`<expected> == <actual>`を評価しているだけだが、
    # エラーメッセージの出力が適切になるためには、第一引数と第二引数の順序を守る。
    assert_equal 'Ruby on Rails Tutorial Sample App',        full_title
    assert_equal 'Help | Ruby on Rails Tutorial Sample App', full_title('Help')
  end
end
