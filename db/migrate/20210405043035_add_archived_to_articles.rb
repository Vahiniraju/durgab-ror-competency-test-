class AddArchivedToArticles < ActiveRecord::Migration[6.1]
  def change
    add_column :articles, :archived, :boolean, default: false, index: true
  end
end
