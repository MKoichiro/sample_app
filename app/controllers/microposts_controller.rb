class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    # user obj に対して、micropost obj を作成する場合には、new ではなく build メソッド。
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_url # login 済みのユーザーのルートページは、非login ユーザーのルートページと表示内容が異なるのでこれで OK。
    else
      # 失敗
      @feed_items = current_user.feed.paginate(page: params[:page]) # リダイレクト先で@feed_items を使うため、ここでも定義
      render 'static_pages/home'
    end
  end

  def destroy
    
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
