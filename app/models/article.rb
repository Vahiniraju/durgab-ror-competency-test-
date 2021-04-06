class Article < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :title, presence: true
  validates :content, presence: true

  default_scope -> { where(archived: false) }

  delegate :name, :email, to: :user, prefix: true
  delegate :name, to: :category, prefix: true

  def self.n_article_ids_by_category(number = 3)
    sql_query = 'select id from ( select id, row_number()' \
      ' over (partition by category_id order by created_at desc)'\
      " as category_rank from articles where archived = false) ranks where category_rank <= #{number};"
    result = ActiveRecord::Base.connection.execute(sql_query)
    result.map { |article| article['id'] }
  end

  def archive
    update_attribute(:archived, true)
  end
end
