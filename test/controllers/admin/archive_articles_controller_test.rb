require 'test_helper'

class Admin::ArchiveArticlesControllerTest < ActionDispatch::IntegrationTest
  %i[user editor].each do |user|
    test "#{user} cannot archive article" do
      sign_in users(user)
      article = articles(:one)
      post admin_archive_article_url(article)
      assert_redirected_to root_path
      assert_equal 'Permission Denied', flash[:notice]
      follow_redirect!
      assert_response :success
    end
  end

  test 'admin archive article should archive article' do
    sign_in users(:admin)
    article = articles(:one)
    post admin_archive_article_url(article)
    assert_redirected_to articles_path
    assert_equal 'Article is archived.', flash[:success]
    follow_redirect!
    assert_response :success
    article.reload
    assert_equal article.archived, true
  end

  test 'admin tries to archive article which is archived' do
    sign_in users(:admin)
    article = articles(:one)
    article.archived = true
    article.save
    post admin_archive_article_url(article)
    assert_redirected_to admin_user_path(article.user)
    assert_equal 'Article is already archived.', flash[:alert]
    follow_redirect!
    assert_response :success
    article.reload
    assert_equal article.archived, true
  end
end
