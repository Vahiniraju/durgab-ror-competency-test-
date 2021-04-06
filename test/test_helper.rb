ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'
require 'minitest/unit'
require 'mocha/minitest'

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all
  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers

  # Add more helper methods to be used by all tests here...
  def assert_redirect(path)
    assert_redirected_to path
    follow_redirect!
    assert_response :success
  end
end
