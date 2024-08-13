class Micropost < ApplicationRecord
  # user モデルとのアソシエーション (user:references で自動生成)
  belongs_to :user
end
