module UsersHelper
  def gravatar_for(user, size = 80)
    # Turn email into a hash with MD5 regardless of its char cases
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    # Gravatar URL
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    # Return an image tag with the gravatar URL
    image_tag(gravatar_url, alt: user.name, class: 'gravatar')
  end
end

# memo: optional な引数の指定
# gravatar_forは、第二引数に関して3通りの書き方がある。
# 1.デフォルト値を指定する
# ```
# def gravatar_for(user, size = 80)
#   puts size # => 80
# end
# ```
#
# 2.キーワード引数を使う
# ```
# def gravatar_for(user, size: 80)
#   puts size # => 80
# end
# ```
#
# 3. ハッシュを使う
# ```
# def gravatar_for(user, options = { size: 80 })
#   size = options[:size]
#   puts size # => 80
# end
# ```
#
# 特に 3 の書き方は、複数のパラメタがデフォルト値を持つ場合に便利。
# 1, 2 は好みの問題。
# デフォルト値を特に定めないが、オプショナルに引数を受け取りたい場合は、（例における 80 の部分で）nil を明示する。
