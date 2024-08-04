class AccountActivationsController < ApplicationController
  
  # REST の原則に従うと、有効化のステータスを更新するという意味で、
  # 本来 PATCH リクエストを送り、updateアクションを呼び出すべきだが、
  # 有効化リンクのクリックによるアクセスなので GET リクエストで受け付けざるを得ない。
  #
  # GET /account_activations/:id/edit?email=example%40example.com
  # params[:id] で有効化トークン、params[:email] でメールアドレスを取得
  def edit
    user = User.find_by(email: params[:email])
    # !user.activated? で、有効化されていないユーザーのみ有効化処理を行う
    # そうしないと、後から何らかの方法でリンクを入手した悪意あるユーザーが、
    # リンクを踏んで有効化し、ログインできるようになってしまう。
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = 'Account activated!'
      redirect_to user
    else
      flash[:danger] = 'Invalid activation link'
      redirect_to root_url
    end
  end
end
