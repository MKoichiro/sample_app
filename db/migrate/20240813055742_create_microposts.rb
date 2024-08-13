class CreateMicroposts < ActiveRecord::Migration[7.1]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    # user_id, created_at の複合キーインデックスを生成
    add_index :microposts, [:user_id, :created_at]
  end
end

# memo 1: add_index
# add_index メソッドの第二引数に配列を指定することで、rails は複数キーインデックスを生成する
# この場合、user_id と created_at の組み合わせでインデックスを生成する
# つまり、find_by(user_id: user.id, created_at: Time.zone.now) で micropost table を検索する際のパフォーマンスが向上する
#
# なお、
# add_index :microposts, :user_id
# add_index :microposts, :created_at
# のような2行のコードは、それぞれ単体で検索する際の設定であり、
# 配列による記述とは根本的に異なる。相互に置き換え不可で、
# どちらかが他方を内包する設定でもないので注意
