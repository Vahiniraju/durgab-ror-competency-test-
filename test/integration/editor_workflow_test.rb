class EditorWorkflowTest < ActionDispatch::IntegrationTest
  test 'should be able to see all my articles' do
    sign_in users(:editor)
    get editor_my_articles_index_url
    assert_select 'div.card strong', 'My Articles'
    assert_select 'table' do
      assert_select 'thead tr' do
        assert_select 'th', 'Title'
        assert_select 'th', 'Content'
        assert_select 'th', 'Category'
        assert_select 'th', 'Archived'
      end

      assert_select 'tbody tr' do
        assert_select 'td', 'MyString2'
        assert_select 'td', 'MyText2'
        assert_select 'td', 'politics'
        assert_select 'td', 'true'
        assert_select 'td a[href=?]', article_path(articles(:two)), 'Show'
        assert_select 'td a[href=?]', edit_article_path(articles(:two)), count: 0
      end

      assert_select 'tbody tr' do
        assert_select 'td', 'MyString'
        assert_select 'td', 'MyText'
        assert_select 'td', 'politics'
        assert_select 'td', 'false'
        assert_select 'td a[href=?]', article_path(articles(:one)), 'Show'
        assert_select 'td a[href=?]', edit_article_path(articles(:one)), 'Edit'
      end
    end
  end
end