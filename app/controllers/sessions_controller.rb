class SessionsController < ApplicationController
  def new
  end

  def create # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user&.authenticate(params[:session][:password]) # 認証処理
      if @user.activated?
        # reset_session の前に、セッションに保存していた URL を変数に一時退避
        forwarding_url = session[:forwarding_url]

        # session id をリセット
        reset_session

        # check box がチェックされている場合、'1' が送信されてくる
        # remember(user): remember_token/digest を生成, cookie に remember_token と user_id を永続的に保存
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)

        # session[:user_id] = user.id で session にユーザーIDをセット
        log_in @user

        redirect_to forwarding_url || @user
      else
        message = 'Account not activated.'
        message += 'Check your email for the activation link.'
        flash[:warning] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out if logged_in?
    # turbo を使用する場合には、`status: :see_other` (303) を指定することでDELETEリクエスト後のリダイレクトを正常に行える。
    redirect_to root_url, status: :see_other
  end
end

# memo: `&.`
# `&.` は `safe navigation operator` または「ぼっち演算子」と呼ばれる。
# `user&.authenticate(params[:session][:password])` は、
# `user && user.authenticate(params[:session][:password])` と同じ意味。
# `obj&.method` は、`obj` が `nil` でない場合のみ、 `method` を実行する。
# 「objが存在するならメソッドを実行」`obj && obj.method` と書くシーンが多いので導入された。

# memo: `flash` と `flash.now`
# `flash` メソッドは、次回リクエスト終了時までその値を保持する。
# `redirect_to` メソッドとは対照的に、`render` メソッドはリクエストを送信するものではない。
# よって、`flash` を `render` と一緒に使用すると、
# `render`による画面再描画後に期待通りフラッシュカードが表示されるところまでは良いが、
# 次の任意の遷移先でもフラッシュメッセージが消えない。(その次のページ遷移で消える。)
# `flash.now` を使うと次回リクエスト前に消えるので `render` メソッドと使用する場合には、`flash.now` が適している。
