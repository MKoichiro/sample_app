class ApplicationController < ActionController::Base
  # 各 controller ファイルは `ApplicatiionContoller` を継承しているため、
  # ここで `mix-in` することで `session_helper` は全ての `controller` で使用可能になる。
  include SessionsHelper

  private

  # ログインしていないユーザーの場合、ログインページにリダイレクトする。
  def logged_in_user
    unless logged_in?
      # friendly forwarding のために、アクセスしようとした URL をセッションに一時退避
      store_location

      flash[:danger] = 'Please log in.'
      # destory アクションの before filter になるため、status: :seeother でリダイレクト。
      redirect_to login_url, status: :see_other
    end
  end
end
