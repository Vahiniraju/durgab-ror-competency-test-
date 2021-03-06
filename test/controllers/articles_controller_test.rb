require 'test_helper'

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test 'articles index page can be visited without any user account' do
    get articles_url
    assert_response :success
  end

  test 'redirected to login page if no user account on show page' do
    article = articles(:one)
    get article_url(article)
    assert_redirect user_session_path
  end

  test 'redirected to login page if no user account on new page' do
    get new_article_url
    assert_redirect user_session_path
  end

  test 'redirected to login page if no user account on edit page' do
    article = articles(:one)
    get edit_article_url(article)
    assert_redirect user_session_path
  end

  test 'only shows 3 record of each category when not logged in' do
    user = users(:editor)
    Article.destroy_all
    %i[sports general politics].each do |cat|
      category = categories(cat)
      4.times do
        Article.create(title: 'title', content: 'content', category_id: category.id, user_id: user.id)
      end
    end
    get articles_url
    assert_equal controller.instance_variable_get(:@articles).total_count, 9
  end

  %i[user admin editor].each do |user|
    test "#{user} can visit index page" do
      sign_in users(user)
      get articles_url
      assert_response :success
    end

    test "#{user} can view show article" do
      article = articles(:one)
      sign_in users(user)
      get article_url(article)
      assert_response :success
    end
  end

  test 'editor can visit new article page' do
    sign_in users(:editor)
    get new_article_url
    assert_response :success
  end

  %i[user admin].each do |user|
    test "#{user} cannot visit new article page" do
      sign_in users(user)
      get new_article_url
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end

    test "#{user} cannot visit edit article page" do
      sign_in users(user)
      article = articles(:one)
      get edit_article_url(article)
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect article_url(article)
    end

    test "#{user} cannot update article" do
      sign_in users(user)
      article = articles(:one)
      patch article_url(article), params: { article: { title: 'updated' } }
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect article_url(article)
    end

    test "#{user} cannot create article" do
      sign_in users(user)
      post articles_path, params: { article: { title: 'updated', content: 'xyz', category_id: categories(:sports).id } }
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end
  end

  test 'when user tries to edit article of another editor it throws permission denied' do
    sign_in users(:editor2)
    article = articles(:one)
    get edit_article_url(article)
    assert_equal 'Permission Denied', flash[:notice]
    assert_redirect article_url(article)
  end

  test 'archived editor cannot create article' do
    sign_in users(:archivedUser)
    post articles_path, params: { article: { title: 'updated', content: 'xyz', category_id: categories(:sports).id } }
    assert_equal 'Permission Denied', flash[:notice]
    assert_redirect root_path
  end

  test 'editor can visit edit page of their article' do
    sign_in users(:editor)
    article = articles(:one)
    get edit_article_url(article)
    assert_response :success
  end

  test 'when user tries to update article of another editor it throws permission denied' do
    sign_in users(:editor2)
    article = articles(:one)
    patch article_url(article), params: { article: { title: 'updated' } }
    assert_equal 'Permission Denied', flash[:notice]
    assert_redirect article_url(article)
  end

  test 'when editor tries to update article of their own it should update' do
    article = articles(:one)
    sign_in article.user
    patch article_url(article), params: { article: { title: 'updated', content: 'xyz',
                                                     category_id: categories(:sports).id } }
    assert_equal 'Article was successfully updated.', flash[:success]
    assert_redirect article_url(article)
    article.reload
    assert_equal 'xyz', article.content
    assert_equal 'updated', article.title
    assert_equal categories(:sports).id, article.category_id
  end

  test 'when editor tries to create article' do
    sign_in users(:editor)
    post articles_path, params: { article: { title: 'updated', content: 'xyz',
                                             category_id: categories(:sports).id } }
    article = controller.instance_variable_get(:@article)
    assert_equal 'Article was successfully created.', flash[:success]
    assert_redirect article_url(article)
    assert_equal 'xyz', article.content
    assert_equal 'updated', article.title
    assert_equal categories(:sports).id, article.category_id
  end

  test 'create article should increase article count' do
    sign_in users(:editor)
    assert_difference -> { Article.count } => 1 do
      post articles_path, params: { article: { title: 'updated', content: 'xyz',
                                               category_id: categories(:sports).id } }
    end
  end

  test 'when editor tries to update article of their own with improper params' do
    article = articles(:one)
    sign_in article.user
    patch article_url(article), params: { article: { title: 'updated', content: '',
                                                     category_id: categories(:sports).id } }
    assert_select 'div#error_explanation ul li', /Content can't be blank/
  end

  test 'when user tries to destroy article of another editor it throws permission denied' do
    sign_in users(:editor2)
    article = articles(:one)
    delete article_url(article), params: { article: { title: 'updated' } }
    assert_equal 'Permission Denied', flash[:notice]
    assert_redirect articles_url
  end

  test 'when editor tries to destroy article of their own it should destroy' do
    article = articles(:one)
    sign_in article.user
    delete article_url(article)
    assert_equal 'Article was successfully destroyed.', flash[:success]
    assert_redirect articles_url
  end

  test 'when editor trying to destroy their article fails' do
    article = articles(:one)
    sign_in article.user
    Article.any_instance.stubs(:destroy).returns(false)
    delete article_url(article)
    assert_equal 'Something went wrong.', flash[:alert]
    assert_redirect articles_url
  end

  %i[user admin editor].each do |user|
    test "#{user} uses search bar" do
      article = articles(:one)
      sign_in users(user)
      get articles_path, params: { search_field: article.title }
      assert_equal controller.instance_variable_get(:@articles).total_count,
                   Article.where('title LIKE ?', "%#{article.title}%").count
      refute_equal controller.instance_variable_get(:@articles).total_count, Article.count
    end

    test "#{user} when no search word is given" do
      sign_in users(:user)
      get articles_path
      assert_equal controller.instance_variable_get(:@articles).total_count,
                   Article.count
    end
  end
end
