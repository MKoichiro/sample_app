class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :correct_user, only: [:edit, :update]

  def new
    # Pass a new User object to form_with in view to create a form for a new user.
    @user = User.new
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # signup 後に自動で login する。
      reset_session
      log_in @user

      flash[:success] = 'Welcome to the Sample App!'

      # redirect_to: GETリクエストを送信して別ページに遷移。
      redirect_to @user
    else
      # 新しいリクエスト無しで、単に再描画。
      # 'new' は、`views/users/new.html.erb` を指す。
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  # Strong parameter: constrain the params that can be passed to the create method, declaring explicitly.
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # Before filters
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

  # 本人でない場合、ホームページにリダイレクトする。
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end
end

# memo 1: `@user`
# 通常、`@` で始まるインスタンス変数は、クラスインスタンス内で共有される。
# ここで同じ `@user` を各アクションで使い回しているのが気になるかもしれない。
# または、`@user`がグローバルに共有されるのではないかと心配するかもしれない。
#
# 「リクエスト受諾 -> "対応する"アクション発火 -> "対応する"ビューのレンダリング」
# という rails のライフサイクルは、HTTP リクエストごとに排反(*)であり、
# 終了すると `@user` のメモリは解放されるため、互いに干渉・共有しない。
# なお、同じライフサイクル内では、`@user` は対応するビューと共有される。
#
# * HTTP リクエストごとにライフサイクルが排反なのは、HTTPリクエストごとに UserController オブジェクトを生成するから

# memo 2: `params`
# `params` ハッシュのようだが、実際には ActionController::Parameters オブジェクト。
#
# GET リクエストの場合、`params` には、URLパラメータがハッシュとして格納される。
# 例えば、`/users/:id` のリクエストに応答するアクションでは、
# `params = { id: value }`
# となる。
#
# POST リクエストの場合、
# `params` には、フォームから送信されたデータがハッシュとして格納される。
# 例えば、form_with によって生成される `<input type="text" name="user[name]" />` というフォームでは、
# `params = { user: { name: value } }`
# となる。

# memo 3: strong parameter
# create メソッドなどで、`User.new(params[:user])` のように、直接 `params` を渡すのは、
# 文法上の間違いはないが、セキュリティ上の問題がある。
# 現在のバージョンでは、この書き方はエラーになる。
# 例えば、dev tool から input の name 属性を変更して、不正なデータを送信することができる。
# より具体的には、like 属性を編集して「いいね」数の不正、admin 属性を付与して管理者権限の不正などが考えられる。

# memo 4: `redirect_to @user`
# `redirect_to user_url(@user)` と等価。
# `user_url(@user)` は、`http://www.example.com/users/:id` にリダイレクトする。

# memo 5: `flash` と `redirect_to`
# `flash` はフラッシュメッセージの表示に使うところから名前が付いたのだろうが本質は、
# リクエスト間で情報を保持するための仕組み。
# 通常のインスタンス変数に格納した値は、ライフサイクルが終了すると消えるが、
# `flash` に格納した値は、次のリクエストまで保持され、そのライフサイクルが終了時（レンダリング後）に消える。
# よって、`flash` は `redirect_to` とセットで使用し、リダイレクト先で `flash` の値を用いてフラッシュメッセージを表示する
# という実装ができる。
