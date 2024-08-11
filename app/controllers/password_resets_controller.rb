class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,        only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash[:danger] = 'Email address not found'
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty? # 再設定パスワードが空文字列の場合
      @user.errors.add(:password, "can't be empty") # ※ @user は before_action で取得済み
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params) # パスワード再設定が成功した場合
      # session 固定攻撃対策
      reset_session

      # 新しいセッションを作成してログイン
      log_in @user

      # reset_digest には、2時間の有効期限を設けている。
      # これは特に公共 PC で、2時間以内に他人が任意のパスワードでログインが可能という脆弱性になる。
      # reset_digest を nil にすることで、再設定を不可能にする。
      @user.update_attribute(:reset_digest, nil)

      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else # 無効なパスワードである場合(@user.update(user_params)でバリデーションではじかれた場合)
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = 'Password reset has expired.'
      redirect_to new_password_reset_url
    end
  end
end
