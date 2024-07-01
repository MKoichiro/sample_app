class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password]) # 認証処理
      reset_session                                    # session id をリセット
      log_in user                                      # session[:user_id] = user.id でsessionにユーザーIDをセット
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new', status: :unprocessable_entity
    end
  end

  def destroy
    log_out
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
