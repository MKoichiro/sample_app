class Micropost < ApplicationRecord
  # user モデルとのアソシエーション (user:references で自動生成)
  belongs_to :user

  # 1つの画像ファイルを関連付け
  has_one_attached :image do |attachable|
    # `:display` は任意の名前、:display というキーでリサイズ後の画像を `variant` から取得できる
    # micropost.image                  :  original版 へのアクセス
    # micropost.image.variant(:display):  display版 へのアクセス
    attachable.variant :display, resize_to_limit: [500, 500]
  end

  # デフォルトの並び順を指定
  default_scope -> { order(created_at: :desc) }
  # 生の SQL クエリで並び替える場合
  # default_scope -> { order('created_at DESC') }
  # 昇順の場合
  # default_scope -> { order(:created_at) }

  # バリデーション
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  # active_storage_validations gem による画像ファイルのバリデーション
  # https://github.com/igorkasyanchuk/active_storage_validations
  validates :image,
    content_type: {
      in: %w[image/jpeg image/gif image/png],
      message: 'must be avalid image format',
    },
    size: {
      less_than: 10.megabytes,
      message: 'should be less than 10MB'
    }
end

# memo 1: has_one_attached
# Active Storage から提供されるメソッドで、1つの画像ファイルを関連付ける。
# 他にも、has_many_attached で複数の画像ファイルを関連付けることもできる。