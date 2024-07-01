module SessionsHelper
  def log_in(user)
    # :user_id というキー名でユーザーIDを保存
    session[:user_id] = user.id
  end

  def current_user
    if session[:user_id]
      # メモ化
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    reset_session
    @current_user = nil
  end
end

# memo 1: `session` メソッド
# - `sessions controller` という命名とは無関係の rails 組み込みメソッド
# - `session[:key] = value` で `:key` をキーとして、暗号化した `value` を一時保持できる。
# - `session[:key]` で復号して値を取り出せる。
# - ブラウザを閉じると有効期限が切れる。
# - `session` はハッシュのように扱えるが、 `ActionDispatch::Request` オブジェクトの一部。

# memo 2: `session` メソッドと「セッションID」
# `session[:key] = value` を実行すると、Rails は自動的にセッションIDを生成する。
# （この自動生成は、ユーザーが初めてアクセスした時や、`reset_session` を実行した直後、
# またはセッションIDがブラウザから送信されなかった場合に限る。）
# 生成されたセッションIDは、ブラウザのクッキーに保存するよう Rails から指示。
# よって、このセッションIDはブラウザに紐づいており、より正確にはアプリケーションのユーザー固有ではない。
# ブラウザは次回以降のリクエスト時にこのセッションIDを Rails に送信。
# RailsはこのセッションIDを使って、ユーザー（正確にはブラウザ）のセッション情報にアクセスできる。(session[:key]でvalueにアクセスする行為に当たる)
# セッション固定攻撃は、攻撃者が自分のセッションIDを別のユーザーに使わせることで、
# そのユーザーのセッションを乗っ取る手法。
# 通常ブラウザを閉じるとセッションIDは破棄されるが、ブラウザのクッキーの設定やアプリの設計によってはセッションIDは保持される。
# セッションを永続化する場合は、この攻撃に対して特に注意が必要。
# ログイン認証後に`reset_session`を実行し、新しいセッションIDを生成することが、セッション固定攻撃への有効な対策。

# memo 3: メモ化
# インスタンス変数を使用して
# `@variable ||= Model.find_by()`
# という形でメモ化できる。
# ただし、メモされているのは、同一のリクエスト内でのみなので、
# 同一のリクエスト内で複数回呼び出される場合のみ有効。
# なお、この書き方は、
# ```
# if @variable
#   @variable = Model.find_by()
# else
#   @variable
# end
# ```
# または、
# ```
# @vaaible = @variable || Model.find_by()
# ```
# と等価。