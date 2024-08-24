class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    # 通常の方法
    # redirect_to (@)user # 正常に動くが、再読み込みが発生する
    
    # Hotwire で実装
    # <action>.turbo_stream.erb が参照され、css id で指定した要素のみを差分レンダリング
    # create.turbo_stream.erb 参照
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    # redirect_to (@)user, status: :see_other
    
    # Hotwire で実装
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end

# memo: respond_to
# respond_to do |format|
#   format.html { redirecte_to @user, status: :see_other }
#   format.turbo_stream
# end
# のブロック内は if-elsif 的に処理される点に注意。
# format 引数には、ファイル形式の識別子が渡る。
# 1 行目は、それがhtml(.erb)形式なら、に通常と同様にリダイレクト処理を行う。
# 2 行目は、それがturbo_stream(.erb)形式なら、に差分レンダリング処理を行う。
# なんらかの理由で、turbo_stream.erbが見つからない場合、通常のhtmlリクエストとして1 行目が実行される。