class EditorWorkflowTest < ActionDispatch::IntegrationTest
  test 'editor creates an article' do
    user = users(:editor)
    sign_in user
    post articles_path params: { article: { title: 'New Article', user_id: user.id, content: 'This is a new article',
                                            category_id: categories(:general).id } }
    new_article = user.articles.where(title: 'New Article').first
    assert_redirect(article_path(new_article))
    assert_select 'div.alert-success', /Article was successfully created./
    assert_select 'div.card' do
      assert_select 'div.card-header', /Article/
      assert_select 'div.card-header a[href=?]', edit_article_url(new_article)
      assert_select 'div.card-body' do
        assert_select 'div.row' do
          assert_select 'strong', /Title :/
          assert_select 'div', /New Article/
        end
        assert_select 'div.row' do
          assert_select 'strong', /Category :/
          assert_select 'div', /general/
        end
        assert_select 'div.row' do
          assert_select 'strong', /Content :/
          assert_select 'div', /This is a new article/
        end
        assert_select 'div.row' do
          assert_select 'strong', /By User :/
          assert_select 'div', /#{user.name}/
        end
        assert_select 'a[href=?]', articles_path
      end
    end
  end

  test 'editor edits an article' do
    user = users(:editor)
    article = articles(:one)
    sign_in user
    get edit_article_path(article)
    assert_response :success
    assert_select 'form[action=?][method=post]', article_path(article) do
      assert_select 'input#article_title[type=text][value=?]', article.title
      assert_select 'select#article_category_id' do
        assert_select 'option[selected=selected]', article.category.name
      end
      assert_select 'textarea#article_content'
      assert_select 'input[type=submit][value=Submit]'
    end
    assert_select 'a[href=?]', articles_path, 'Back to Articles'
  end

  test 'editor updates an article' do
    user = users(:editor)
    article = articles(:one)
    sign_in user
    put article_path(article),
        params: { article: { id: article.id, title: 'Updated Title', content: 'This is updated content' } }
    assert_redirect(article_path(article))
    assert_select 'div.alert-success', /Article was successfully updated./
    assert_select 'div.card' do
      assert_select 'div.card-header', /Article/
      assert_select 'div.card-header a[href=?]', edit_article_url(article)
      assert_select 'div.card-body' do
        assert_select 'div.row' do
          assert_select 'strong', /Title :/
          assert_select 'div', /Updated Title/
        end
        assert_select 'div.row' do
          assert_select 'strong', /Content :/
          assert_select 'div', /This is updated content/
        end
        assert_select 'div.row' do
          assert_select 'strong', /By User :/
          assert_select 'div', /#{user.name}/
        end
        assert_select 'a[href=?]', articles_path
      end
    end
  end

  test 'editor deletes an article' do
    user = users(:editor)
    article = articles(:one)
    sign_in user
    delete article_path(article)
    assert_redirect(articles_url)
    assert_select 'div.alert-success', /Article was successfully destroyed./
  end

  test 'editor accesses my articles page' do
    sign_in users(:editor)
    get editor_my_articles_index_url
    assert_select 'div.card strong', 'My Articles'
    assert_select 'div.card-header a[href=?]', new_article_path, 'Create Article'
    assert_select 'table' do
      assert_select 'thead tr' do
        assert_select 'th', 'Title'
        assert_select 'th', 'Content'
        assert_select 'th', 'Category'
        assert_select 'th', 'Archived'
      end

      assert_select 'tbody tr' do
        assert_select 'td', 'Governer Races'
        assert_select 'td', 'MyText2'
        assert_select 'td', 'politics'
        assert_select 'td', 'true'
        assert_select 'td a[href=?]', article_path(articles(:two)), 'Show'
        assert_select 'td a[href=?]', edit_article_path(articles(:two)), count: 0
      end

      assert_select 'tbody tr' do
        assert_select 'td', 'Governer Races'
        assert_select 'td', 'MyText'
        assert_select 'td', 'politics'
        assert_select 'td', 'false'
        assert_select 'td a[href=?]', article_path(articles(:one)), 'Show'
        assert_select 'td a[href=?]', edit_article_path(articles(:one)), 'Edit'
      end
    end
  end

  test 'editor accesses home page' do
    sign_in users(:editor2)
    get articles_url
    assert_select 'div.card strong', 'Articles'
    assert_select 'div.card-header a[href=?]', new_article_path, 'Create Article'
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

      assert_select 'tfoot' do
        assert_select 'span.current', '1'
        assert_select 'span.next a[href=?]', '/?page=2'
      end
    end
  end

  test 'archived editor accesses my articles page' do
    archived_user = users(:archivedUser)
    sign_in archived_user

    get editor_my_articles_index_url
    assert_select 'div.card strong', 'My Articles'
    assert_select 'div.card-header a[href=?]', new_article_path, count: 0
  end

  test 'archived editor accesses home page' do
    sign_in users(:archivedUser)
    get articles_url
    assert_select 'div.card strong', 'Articles'
    assert_select 'div.card-header a[href=?]', new_article_path, count: 0
  end
end
