class ApplicationController < ActionController::Base
  # 各 controller ファイルは `ApplicatiionContoller` を継承しているため、
  # ここで `mix-in` することで `session_helper` は全ての `controller` で使用可能になる。
  include SessionsHelper
end
