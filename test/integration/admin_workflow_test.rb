class AdminWorkflowTest < ActionDispatch::IntegrationTest
  test 'admin can see list of users' do
    user = users(:admin)
    sign_in user
    get admin_users_path
    assert_response :success
    assert_select 'div.card' do
      assert_select 'div.card-header', /Users/
      assert_select 'div.card-header a[href=?]', new_admin_user_path, 'Create User'
    end
    assert_select 'table' do
      assert_select 'thead tr' do
        assert_select 'th', 'Email'
        assert_select 'th', 'Name'
        assert_select 'th', 'Role'
        assert_select 'th', 'Archived'
      end
      User.all.page(1).each do |u|
        assert_select 'tbody tr' do
          assert_select 'td', u.email
          assert_select 'td', u.name
          assert_select 'td', u.role.to_s
          assert_select 'td', u.archived.to_s
          assert_select 'td a[href=?]', admin_user_path(user)
          assert_select 'td a[href=?]', edit_admin_user_path(user)
        end
      end
    end
  end

  test 'admin can edit user' do
    to_edit_user = users(:one)
    sign_in users(:admin)
    get edit_admin_user_path(to_edit_user)
    assert_response :success
    assert_select 'div.card' do
      assert_select 'div.card-header', /Edit User/
    end
    assert_select 'form[action=?][method=post]', admin_user_path(to_edit_user) do
      assert_select 'input#user_email[type=text][value=?]', to_edit_user.email
      assert_select 'input#user_name[type=text][value=?]', to_edit_user.name
      assert_select 'select#user_roles' do
        assert_select 'option[selected=selected]', to_edit_user.role.to_s
      end
      assert_select 'input[type=submit][value=Submit]'
    end
    assert_select 'a[href=?]', admin_user_path(to_edit_user), 'Back to User'
  end

  test 'admin can archive user' do
    to_archive_user = users(:one)
    sign_in users(:admin)
    post admin_archive_user_path(to_archive_user)
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select 'div.alert-success', /User archived along with their articles./
    assert_select 'div.card' do
      assert_select 'div.card-header', /User/
      assert_select 'div.card-header a[href=?]', edit_admin_user_path(to_archive_user)
      assert_select 'div.card-header a[href=?]', admin_archive_user_path(to_archive_user), count: 0
    end
    assert_select 'div.card-body' do
      assert_select 'div.row' do
        assert_select 'strong', /Email :/
        assert_select 'div', to_archive_user.email
      end
      assert_select 'div.row' do
        assert_select 'strong', /Name :/
        assert_select 'div', to_archive_user.name
      end
      assert_select 'div.row' do
        assert_select 'strong', /Role :/
        assert_select 'div', to_archive_user.role.to_s
      end
      assert_select 'div.row' do
        assert_select 'strong', /Archived/
        assert_select 'div', /true/
      end
      assert_select 'a[href=?]', admin_users_path
    end
  end

  test 'admin can see individual user page' do
    user = users(:one)
    sign_in users(:admin)
    get admin_user_path(user)
    assert_response :success
    assert_select 'div.card' do
      assert_select 'div.card-header', /User/
      assert_select 'div.card-header a[href=?][data-confirm=?][data-method=post]', admin_archive_user_path(user),
                    "Are you sure, you want to archive the user with email?: #{user.email}"
    end
    assert_select 'div.card-body' do
      assert_select 'div.row' do
        assert_select 'strong', /Email :/
        assert_select 'div', user.email
      end
      assert_select 'div.row' do
        assert_select 'strong', /Name :/
        assert_select 'div', user.name
      end
      assert_select 'div.row' do
        assert_select 'strong', /Role :/
        assert_select 'div', user.role.to_s
      end
      assert_select 'div.row' do
        assert_select 'strong', /Archived :/
        assert_select 'div', /#{user.archived}/
      end
      assert_select 'a[href=?]', admin_users_path
    end
  end

  test 'admin accesses home page' do
    sign_in users(:admin)
    get articles_url
    assert_select 'div.card strong', 'Articles'
    assert_select 'table' do
      assert_select 'thead tr' do
        assert_select 'th', 'Title'
        assert_select 'th', 'Content'
        assert_select 'th', 'Category'
        assert_select 'th', 'User'
      end

      assert_select 'tbody tr td a[href=?]', article_path(articles(:two)), count: 0

      assert_select 'tbody tr' do
        assert_select 'td', 'MyString'
        assert_select 'td', 'MyText'
        assert_select 'td', 'politics'
        assert_select 'td', users(:editor).name
        assert_select 'td a[href=?]', article_path(articles(:one)), 'Show'
      end

      assert_select 'tbody tr' do
        assert_select 'td', 'sportsTitle'
        assert_select 'td', 'sportsContent'
        assert_select 'td', 'sports'
        assert_select 'td', users(:editor2).name
        assert_select 'td a[href=?]', article_path(articles(:sport)), 'Show'
      end
    end
  end

  test 'admin creates a new user' do
    user = users(:admin)
    sign_in user
    post admin_users_path params: { user: { email: 'new@example.com', name: 'New John Doe', role: 'user' } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    new_user = User.where(email: 'new@example.com').first
    assert_select 'div.alert-success', /User Account Created./
    assert_select 'div.card' do
      assert_select 'div.card-header', /User/
      assert_select 'div.card-header a[href=?][data-confirm=?][data-method=post]', admin_archive_user_path(new_user),
                    "Are you sure, you want to archive the user with email?: #{new_user.email}"
    end
    assert_select 'div.card-body' do
      assert_select 'div.row' do
        assert_select 'strong', /Email :/
        assert_select 'div', new_user.email
      end
      assert_select 'div.row' do
        assert_select 'strong', /Name :/
        assert_select 'div', new_user.name
      end
      assert_select 'div.row' do
        assert_select 'strong', /Role :/
        assert_select 'div', new_user.role.to_s
      end
      assert_select 'div.row' do
        assert_select 'strong', /Archived :/
        assert_select 'div', /#{new_user.archived}/
      end
      assert_select 'a[href=?]', admin_users_path
    end
  end

  test 'admin updates a user' do
    user = users(:admin)
    to_be_updated_user = users(:one)
    sign_in user
    put admin_user_path(to_be_updated_user), params: { user: { id: to_be_updated_user.id, name: 'Updated Name' } }
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select 'div.alert-success', /User Account Updated./
    assert_select 'div.card' do
      assert_select 'div.card-header', /User/
      assert_select 'div.card-header a[href=?][data-confirm=?][data-method=post]',
                    admin_archive_user_path(to_be_updated_user),
                    "Are you sure, you want to archive the user with email?: #{to_be_updated_user.email}"
    end
    assert_select 'div.card-body' do
      assert_select 'div.row' do
        assert_select 'strong', /Email :/
        assert_select 'div', to_be_updated_user.email
      end
      assert_select 'div.row' do
        assert_select 'strong', /Name :/
        assert_select 'div', 'Updated Name'
      end
      assert_select 'div.row' do
        assert_select 'strong', /Role :/
        assert_select 'div', to_be_updated_user.role.to_s
      end
      assert_select 'div.row' do
        assert_select 'strong', /Archived :/
        assert_select 'div', /#{to_be_updated_user.archived}/
      end
      assert_select 'a[href=?]', admin_users_path
    end
  end
end
