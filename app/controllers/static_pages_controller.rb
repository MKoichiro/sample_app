class StaticPagesController < ApplicationController
  def home
    # home action は login 済みかどうかで、view を描き分ける。
    # login 済みで無くても、home action はあっても構わないし、今後の実装次第では使いうるということ。
    # よって、before_action でログイン済みかどうかを確認して、login 済みでなければ home action を実行しないようにするのは、柔軟性を損なう。
    # ここでは、単に条件分岐で対応する。
    if logged_in?
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
