require 'test_helper'

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  %i[user editor].each do |user|
    test "#{user} visit index page should throw permission denied" do
      sign_in users(user)
      get admin_users_url
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end

    test "#{user} visit edit page should throw permission denied" do
      local_user = users(user)
      sign_in local_user
      get edit_admin_user_url(local_user)
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end

    test "#{user} visit new page should throw permission denied" do
      sign_in users(:user)
      get new_admin_user_url
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end

    test "#{user} create action should throw permission denied" do
      sign_in users(:user)
      post admin_users_url, params: { user: { email: 'xyz@abc.com', roles: 'editor', name: 'Foobar' } }
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end

    test "#{user} update action should throw permission denied" do
      local_user = users(user)
      sign_in local_user
      patch admin_user_url(local_user), params: { user: { email: 'xyz@abc.com', roles: 'editor', name: 'Foobar' } }
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end

    test "#{user} show page should throw permission denied" do
      local_user = users(user)
      sign_in local_user
      get admin_user_url(local_user)
      assert_equal 'Permission Denied', flash[:notice]
      assert_redirect root_path
    end
  end

  test 'visit index page should throw permission denied when user not signed_in' do
    get admin_users_url
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    assert_redirect user_session_path
  end

  test 'visit edit page should throw permission denied when user not signed_in' do
    user = users(:one)
    get edit_admin_user_url(user)
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    assert_redirect user_session_path
  end

  test 'visit new page should throw permission denied when user not signed_in' do
    get new_admin_user_url
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    assert_redirect user_session_path
  end

  test 'create action should throw permission denied when user not signed_in' do
    post admin_users_url, params: { user: { email: 'xyz@abc.com', roles: 'editor', name: 'Foobar' } }
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    assert_redirect user_session_path
  end

  test 'update action should throw permission denied when user not signed_in' do
    user = users(:one)
    patch admin_user_url(user), params: { user: { email: 'xyz@abc.com', roles: 'editor', name: 'Foobar' } }
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    assert_redirect user_session_path
  end

  test 'show page should throw permission denied when user not signed_in' do
    user = users(:one)
    get admin_user_url(user)
    assert_equal 'You need to sign in or sign up before continuing.', flash[:alert]
    assert_redirect user_session_path
  end

  test 'admin visit index page should have users equal to User.count' do
    sign_in users(:admin)
    get admin_users_url
    assert_response :success
    assert_equal controller.instance_variable_get(:@users).total_count, User.count
    assert_template :index
  end

  test 'admin visit edit page should have user instance variable' do
    sign_in users(:admin)
    user = users(:one)
    get edit_admin_user_url(user)
    assert_response :success
    assert_equal controller.instance_variable_get(:@user), user
    assert_template :edit
  end

  test 'admin visit new page should have user instance variable' do
    sign_in users(:admin)
    get new_admin_user_url
    assert_response :success
    assert_instance_of User, controller.instance_variable_get(:@user)
    assert_template :new
  end

  test 'admin create action should create new user' do
    sign_in users(:admin)
    post admin_users_url, params: { user: { email: 'xyz@abc.com', roles: 'editor', name: 'Foobar' } }
    user = controller.instance_variable_get(:@user)
    assert_equal 'User Account Created.', flash[:success]
    assert_redirect admin_user_path(user)
  end

  test 'admin create user should increase user count' do
    assert_difference('User.count', 1) do
      sign_in users(:admin)
      post admin_users_url, params: { user: { email: 'xyz11@abc.com', roles: 'editor', name: 'Foobar' } }
    end
  end

  test 'admin update action should update user' do
    user = users(:admin)
    sign_in users(:admin)
    patch admin_user_url(user), params: { user: { email: 'xyzz@abc.com', roles: 'admin', name: 'Foobar' } }
    updated_user = controller.instance_variable_get(:@user)
    assert_equal user.id, updated_user.id
    assert_equal 'User Account Updated.', flash[:success]
    assert_redirect admin_user_path(user)
  end

  test 'admin show page should user_info' do
    user = users(:admin)
    sign_in users(:admin)
    get admin_user_url(user)
    show_user = controller.instance_variable_get(:@user)
    assert_equal user.id, show_user.id
    assert_template :show
  end

  test 'uses search bar' do
    user = users(:admin)
    sign_in user
    get admin_users_path, params: { search_field: user.email }
    assert_equal controller.instance_variable_get(:@users).total_count,
                 User.where('email LIKE ?', "%#{user.email}%").count
    refute_equal controller.instance_variable_get(:@users).total_count, User.count
  end

  test 'when no search word is given' do
    user = users(:admin)
    sign_in user
    get admin_users_path
    assert_equal controller.instance_variable_get(:@users).total_count,
                 User.count
  end

  def assert_redirect(path)
    assert_redirected_to path
    follow_redirect!
    assert_response :success
  end
end
