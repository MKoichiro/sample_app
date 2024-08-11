class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.account_activation.subject
  #
  def account_activation(user)
    # コントローラーのインスタンス変数がビューで使えるのと同様に、メーラーのインスタンス変数もビューで使える
    @user = user

    # mail メソッドで送信するメールの情報を設定
    # 実際の送信は、適切なアクションにて、`UserMailer.account_activation(user).deliver_now` で行う
    mail to: user.email, subject: 'Account activation'
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.password_reset.subject
  #
  def password_reset(user)
    @user = user
    mail to: user.email, subject: 'Password reset'
  end
end
