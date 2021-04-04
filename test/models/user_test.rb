require "test_helper"

class UserTest < ActiveSupport::TestCase
  test 'user' do
    assert_equal 2, User.count
  end
end
