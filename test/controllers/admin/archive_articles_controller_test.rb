require 'test_helper'

class Admin::ArchiveArticlesControllerTest < ActionDispatch::IntegrationTest
  %i[user editor].each do |user|
    test "#{user} cannot archive article" do
      sign_in users(user)
      article = articles(:one)
      post admin_archive_article_url(article)
      assert_redirected_to root_path
      assert_equal 'Permission Denied', flash[:notice]
    end
  end

  test 'admin archive article should archive article' do
    sign_in users(:admin)
    article = articles(:one)
    post admin_archive_article_url(article)
    assert_redirected_to article_path(article)
    assert_equal 'Article is archived.', flash[:success]
    article.reload
    assert_equal article.archived, true
  end
end
