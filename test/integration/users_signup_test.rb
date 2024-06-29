require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  # 無効なユーザーデータではサインアップできてはならない
  test 'invalid signup information' do
    # 省略可能だが、実際のユーザーの手順通りにまずは '/signup' にアクセスする
    get signup_path
    # ブロックの処理前後で User.count が変わらない（ユーザーが追加されない）ことを確認
    assert_no_difference 'User.count' do
      # 無効な 'params' でPOSTリクエストを送信
      post users_path, params: {
        user: {
          name: '',
          email: 'user@invalid',
          password: 'foo',
          password_confirmation: 'bar'
        }
      }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new'

    # エラーメッセージが表示されていることを確認
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
  end

  # 有効なユーザーデータではサインアップできるべき
  test 'valid signup information' do
    get signup_path
    # ブロックの処理前後で User.count が 1 増えることを確認
    assert_difference 'User.count', 1 do
      post users_path, params: {
        user: {
          name: 'Example Taro',
          email: 'taro@example.com',
          password: 'tutorial',
          password_confirmation: 'tutorial'
        }
      }

      # リダイレクト先に移動
      follow_redirect!
      assert_template 'users/show'

      # リダイレクト先でフラッシュメッセージが表示されていることを確認
      assert_not flash.empty?
    end
  end
end
