require 'test_helper'

class Admin::ArchiveUsersControllerTest < ActionDispatch::IntegrationTest
  %i[user editor].each do |user|
    test "#{user} cannot archive user" do
      sign_in users(user)
      article = articles(:one)
      post admin_archive_user_url(article.user.id)
      assert_redirected_to root_path
      assert_equal 'Permission Denied', flash[:notice]
    end
  end

  test 'admin archive user should archive user and its articles' do
    sign_in users(:admin)
    article = articles(:one)
    post admin_archive_user_url(article.user.id)
    assert_redirected_to admin_user_path(article.user)
    assert_equal 'User archived along with their articles.', flash[:success]
    article.reload
    assert_equal article.archived, true
    assert_equal article.user.archived, true
  end

  test 'admin tries to user article which is archived' do
    sign_in users(:admin)
    user = users(:one)
    user.archived = true
    user.save
    post admin_archive_user_url(user)
    assert_redirected_to admin_user_path(user)
    assert_equal 'User is already archived.', flash[:alert]
    user.reload
    assert_equal user.archived, true
  end
end
