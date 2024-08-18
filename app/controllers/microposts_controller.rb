class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

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
    @micropost.destroy
    flash[:success] = 'Micropost deleted'

    # test 環境ではブラウザを介さないため referrer が定義されず nil になるので、分岐が必要。
    if request.referrer.nil?
      redirect_to root_url, status: :see_other
    else
      # delete btn は user/show と static_pages/home の二か所にパーシャルで読み込まれる。
      # どちらにも対応できるように、`request.referrer`で直前のページにリダイレクト
      redirect_to request.referrer, status: :see_other
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content)
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    redirect_to root_url, status: :see_other if @micropost.nil?
  end
end
