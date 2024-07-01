ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/reporters'
Minitest::Reporters.use!

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # app/helpers/application_helper.rbのApplicationHelperモジュールを継承して
    # full_titleメソッドをテストコード内で使用できるようにする
    include ApplicationHelper

    # Add more helper methods to be used by all tests here...
    def is_logged_in?
      session[:user_id].present?
    end
  end
end
