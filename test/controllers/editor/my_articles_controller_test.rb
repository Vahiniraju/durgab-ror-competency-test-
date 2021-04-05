require 'test_helper'

class Editor::MyArticlesControllerTest < ActionDispatch::IntegrationTest
  %i[user admin].each do |user|
    test "#{user} visit my articles page should return permission denied" do
      sign_in users(user)
      get editor_my_articles_index_url
      assert_redirected_to root_path
      assert_equal 'Permission Denied', flash[:notice]
    end
  end

  test 'user with no login visit my articles page' do
    get editor_my_articles_index_url
    assert_redirected_to user_session_path
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
  end

  test 'editor visit my controllers page' do
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
  end
end
