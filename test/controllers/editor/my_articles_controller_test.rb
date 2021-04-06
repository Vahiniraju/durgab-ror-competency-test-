require 'test_helper'

class Editor::MyArticlesControllerTest < ActionDispatch::IntegrationTest
  %i[user admin].each do |user|
    test "permission denied when #{user} visits my articles page" do
      sign_in users(user)
      get editor_my_articles_index_url
      assert_redirected_to root_path
      assert_equal 'Permission Denied', flash[:notice]
      follow_redirect!
      assert_response :success
    end
  end

  test 'a user who is not logged in cannot access index page' do
    get editor_my_articles_index_url
    assert_redirected_to user_session_path
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    follow_redirect!
    assert_response :success
  end

  test 'only editor can access index page' do
    editor = users(:editor)
    sign_in editor
    get editor_my_articles_index_url
    assert_response :success
    assert_template :index
    # editor role changed to user
    editor.roles = 'user'
    editor.save
    editor.reload
    get editor_my_articles_index_url
    assert_redirected_to root_path
    assert_equal 'Permission Denied', flash[:notice]
    follow_redirect!
    assert_response :success
  end

  test 'editor use search bar' do
    article = articles(:one)
    sign_in article.user
    get editor_my_articles_index_url, params: { search_field: article.title }
    assert_equal controller.instance_variable_get(:@articles).total_count,
                 article.user.unscoped_articles.where('title LIKE ?', "%#{article.title}%").count
  end

  test 'editor when no search word is given' do
    article = articles(:one)
    sign_in article.user
    get editor_my_articles_index_url
    assert_equal controller.instance_variable_get(:@articles).total_count,
                 article.user.unscoped_articles.count
  end
end
