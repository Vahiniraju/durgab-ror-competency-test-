require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  test 'article cannot be saved when title is nil' do
    article = articles(:one)
    article.title = nil
    refute(article.save)
    assert_includes article.errors.full_messages, "Title can't be blank"
  end

  test 'title cannot be empty string' do
    article = articles(:one)
    article.title = '   '
    refute(article.save)
    assert_includes article.errors.full_messages, "Title can't be blank"
  end

  test 'content cannot be empty string' do
    article = articles(:one)
    article.content = '   '
    refute(article.save)
    assert_includes article.errors.full_messages, "Content can't be blank"
  end

  test 'article not save when category is nil' do
    article = articles(:one)
    article.category_id = nil
    refute(article.save)
    assert_includes article.errors.full_messages, 'Category must exist'
  end

  test 'have error when category id does not exist' do
    article = articles(:one)
    article.category_id = Category.maximum(:id) + 1
    refute(article.save)
    assert_includes article.errors.full_messages, 'Category must exist'
  end

  test 'have error when category is not assigned to article' do
    article = articles(:one)
    article.category_id = nil
    refute(article.save)
    assert_includes article.errors.full_messages, 'Category must exist'
  end

  test 'have error when user is not assigned to article' do
    article = articles(:one)
    article.user_id = nil
    refute(article.save)
    assert_includes article.errors.full_messages, 'User must exist'
  end

  test 'have error when user id does not exist' do
    article = articles(:one)
    article.user_id = User.maximum(:id) + 1
    refute(article.save)
    assert_includes article.errors.full_messages, 'User must exist'
  end

  test 'save when everything is given in article properly' do
    article = articles(:one)
    assert article
  end

  test 'default scope' do
    article = Article.find_by_id(articles(:archived).id)
    assert article.nil?, true
  end

  test 'respond to user_name' do
    article = articles(:one)
    assert_equal article.user_name, article.user.name
  end

  test 'respond to user_email' do
    article = articles(:one)
    assert_equal article.user_email, article.user.email
  end

  test 'respond to category_name' do
    article = articles(:one)
    assert_equal article.category_name, article.category.name
  end

  test 'respond to category' do
    article = articles(:one)
    assert_equal article.category.class, Category
  end

  test 'respond to user' do
    article = articles(:one)
    assert_equal article.user.class, User
  end
end
