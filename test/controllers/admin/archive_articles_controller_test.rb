require 'test_helper'

class Admin::ArchiveArticlesControllerTest < ActionDispatch::IntegrationTest
  %i[user editor].each do |user|
    test "#{user} cannot archive article" do
      sign_in users(user)
      article = articles(:one)
      post admin_archive_article_url(article)
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end
  end

  test 'admin archive article should archive article' do
    sign_in users(:admin)
    article = articles(:one)
    post admin_archive_article_url(article)
    assert_equal 'Article is archived.', flash[:success]
    assert_redirect articles_path
    article.reload
    assert_equal article.archived, true
  end

  test 'admin tries to archive article which is archived' do
    sign_in users(:admin)
    article = articles(:one)
    article.archived = true
    article.save
    post admin_archive_article_url(article)
    assert_equal 'Article is already archived.', flash[:alert]
    assert_redirect admin_user_path(article.user)
    article.reload
    assert_equal article.archived, true
  end

  def assert_redirect(path)
    assert_redirected_to path
    follow_redirect!
    assert_response :success
  end
end
