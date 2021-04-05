require 'test_helper'

class CategoryTest < ActiveSupport::TestCase
  test 'does have error message regard name must present' do
    category = Category.new
    refute(category.save)
    assert_includes category.errors.full_messages, "Name can't be blank"
  end

  test 'error message about name lenght' do
    category = Category.new
    category.name = 'xxxxxxxxxxxxxxxxxxxxxxxxxxx'
    refute(category.save)
    assert_includes category.errors.full_messages, 'Name is too long (maximum is 25 characters)'
  end

  test 'respond to articles' do
    category = categories(:sports)
    assert_equal category.articles.present?, true
  end
end
