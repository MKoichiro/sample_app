class Micropost < ApplicationRecord
  # user モデルとのアソシエーション (user:references で自動生成)
  belongs_to :user

  # デフォルトの並び順を指定
  default_scope -> { order(created_at: :desc) }
  # 生の SQL クエリで並び替える場合
  # default_scope -> { order('created_at DESC') }
  # 昇順の場合
  # default_scope -> { order(:created_at) }

  # バリデーション
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
