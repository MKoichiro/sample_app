class Relationship < ApplicationRecord
  # follower_id を User table の 内部 id に対する Relationship オブジェクトの外部 id として紐づけ
  # (Relationship object).follower で、User table から、follower_id と一致する User オブジェクトが取得可能に
  belongs_to :follower, class_name: 'User'
  # 同上
  belongs_to :followed, class_name: 'User'

  validates :follower_id, presence: true
  validates :followed_id, presence: true
end
