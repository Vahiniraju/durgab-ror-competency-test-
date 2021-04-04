# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_users
  users = [
    { email: 'user@xyz.com', password: 'password', password_confirmation: 'password' },
    { email: 'editor1@xyz.com', password: 'password', password_confirmation: 'password', role: 'editor' },
    { email: 'editor2@xyz.com', password: 'password', password_confirmation: 'password', role: 'editor' },
    { email: 'editor3@xyz.com', password: 'password', password_confirmation: 'password', role: 'editor' },
    { email: 'admin@xyz.com', password: 'password', password_confirmation: 'password', role: 'admin' }
  ]

  users.each do |user|
    new_user = User.new(user)
    new_user.skip_confirmation!
    new_user.save!
  end

  puts "#{User.count} users created"
end

def create_categories
  categories = [
    { name: 'politics' },
    { name: 'general' },
    { name: 'sports' }
  ]

  Category.create(categories)
  puts "#{Category.count} categories created"
end

def create_articles
  category_ids = Category.pluck(:id)
  editors = User.role_editors
  raise '3 Categories not found' unless category_ids.count == 3
  raise '3 editors not found' unless editors.count == 3

  articles = [
    { title: 'PoliticsName', content: 'PoliticsContent', category_id: category_ids[0] },
    { title: 'SportsName', content: 'SportsContent', category_id: category_ids[1] },
    { title: 'GeneralName', content: 'GeneralContent', category_id: category_ids[2] }
  ]

  editors.each do |editor|
    articles.map { |x| x[:user_id] = editor.id }
    Article.create(articles)
  end

  Article.create({ title: 'PoliticsName', content: 'PoliticsContent',
                   category_id: category_ids[0], user_id: editors.first.id })
  puts "#{Article.count} articles created"
end

ApplicationRecord.transaction do
  create_users
  create_categories
  create_articles
end
