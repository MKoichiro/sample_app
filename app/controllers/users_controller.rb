class UsersController < ApplicationController
  def new
    # Pass a new User object to form_with in view to create a form for a new user.
    @user = User.new
  end

  def show
    @user = User.find(params[:id])
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
# `params` は、URLパラメータを格納するハッシュ。
# 例えば、`/users/:id` のリクエストに応答するアクションでは、
# `params = { id: value }`
# となる。
