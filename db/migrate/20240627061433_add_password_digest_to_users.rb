class AddPasswordDigestToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_digest, :string
  end
end

# memo 1: 生成コマンドの Convention
# このファイルは、`rails g migration add_password_digest_to_users password_digest:string` で生成。
# ファイル名指定部は `add_*_to_models` という命名をすると、次のような自動生成が行われる。
# 1. そのファイル名で、Add*ToModels というクラスが生成され、
# 2. その中に add_column メソッドが記述される。
# `*` は任意だが、普通カラム名を指定する。
# "add" や "to_models" などのキーワードが無いと、`add_column` メソッドは自動生成されない。
#
# ファイル名などを任意に決めて、一から自分で書いても問題はないが、
# 特に理由が無ければ、Convention に従えば自動生成も効くので楽、という話。

# memo 2: `add_column` メソッド
# `create_table` メソッドでテーブルを作成した後に、テーブルにカラムを追加するためのメソッド。
# `create_table` で入れ忘れたカラムや、後から必要性が出てきたカラムを追加するときに使う。
# 例によって、`create_tabel` ブロック内で初めから、`t.string :password_digest` としても問題はない。
