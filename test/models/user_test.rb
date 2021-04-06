require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'unscoped_articles to include archived articles' do
    user = users(:editor2)
    assert_includes user.unscoped_articles, articles(:archived)
  end

  test 'user should not be valid if no name' do
    user = users(:one)
    user.name = nil
    refute user.valid?
  end

  test 'unscoped_articles return empty array when not found' do
    user = users(:admin)
    assert_equal user.unscoped_articles, []
  end

  test 'set_password will set password and password_confimation' do
    user = User.new
    assert_equal user.password.nil?, true
    assert_equal user.password_confirmation.nil?, true
    user.set_password
    assert_equal user.password.nil?, false
    assert_equal user.password_confirmation.nil?, false
  end

  test 'test call_back for archived user will archive its articles' do
    user = users(:editor2)
    assert_includes user.unscoped_articles.pluck(:archived).uniq, true
    assert_includes user.unscoped_articles.pluck(:archived).uniq, false
    user.archived = true
    user.save
    assert_includes user.unscoped_articles.pluck(:archived).uniq, true
    assert_not_includes user.unscoped_articles.pluck(:archived).uniq, false
  end

  test 'user responds to articles' do
    user = users(:editor2)
    assert_equal user.articles.present?, true
  end
end
