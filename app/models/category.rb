class Category < ApplicationRecord
  validates :name, presence: true, length: { maximum: 25 }

  has_many :articles
end
