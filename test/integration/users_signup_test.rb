require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
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
end
