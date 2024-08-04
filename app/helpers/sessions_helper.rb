module SessionsHelper
  def log_in(user)
    # :user_id というキー名でユーザーIDを保存
    session[:user_id] = user.id

    # セッションリプレイ攻撃から保護 (https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443)
    session[:session_token] = user.session_token
  end

  # ユーザーを永続的セッションに記憶する
  def remember(user)
    # remember_token を発行、DB にはハッシュ化して remember_digest として保存
    user.remember

    # ブラウザの cookie に対して...
    # 1. ユーザーID を暗号化して保存
    cookies.permanent.encrypted[:user_id] = user.id
    # 2. remember_token を保存
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 永続的セッションを破棄
  def forget(user)
    user.forget

    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def current_user
    if (user_id = session[:user_id])              # [短期的] session に保存されたユーザーIDがある場合
      user = User.find_by(id: user_id)
      @current_user = user if user && session[:session_token] == user.session_token
    elsif (user_id = cookies.encrypted[:user_id]) # [永続的] cookie に保存されたユーザーIDがある場合
      user = User.find_by(id: user_id)
      if user&.authenticated?(:remember, cookies[:remember_token])
        # ユーザーが存在し、かつ remember_token(cookies) と remember_digest(DB) が整合する場合
        log_in user
        @current_user = user
      end
    end
  end

  # 本人確認（渡されたユーザーが現在のユーザーであれば true を返す）
  def current_user?(user)
    user && user == current_user
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end

  # friendly forwarding のために、
  # アクセスしようとようとした URL をセッションに保存
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
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

# memo: `cookies` メソッド
# - `cookies` は、ブラウザのクッキーにアクセスするためのメソッド。
# `cookies[:key] = { value: value, expires: time }`` で、有効期限付きでクッキーに保存できる。
# `cookies.permanent[:key] = value` は、
# `cookies[:key] = { value: value, expires: 20.years.from_now.utc }` と等価。
# 20年というのはセッション永続化のために、慣習的によく使われる値。
# また、`cookies.permanent.encrypted[:key] = value` で、暗号化して保存できる。

# memo: `user_id` の暗号化と非暗号の `remember_token`
# `user_id` の場合
# - 一意性を持つ
# - インクリメンタルな整数値で予測可能
# という性質上、暗号化して保存することで、ユーザーIDを隠蔽する。
#
# `remember_token` の場合
# - 一意性を持つ必要は無い(確率的に一意性は高い)
# - ランダムで複雑な `Base64` 文字列
# という性質上、暗号化する必要がない。
# サーバー(DB)側でハッシュ化して保存し、クライアント(cookies)側ではプレーンテキストで保存する。
