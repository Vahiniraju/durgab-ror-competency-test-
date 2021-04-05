# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

def create_users
  users = [
    { email: 'foo@example.com', password: 'password', password_confirmation: 'password', name: 'John Doe' },
    { email: 'editor1@example.com', password: 'password', password_confirmation: 'password', role: 'editor',
      name: 'John Editor' },
    { email: 'editor2@example.com', password: 'password', password_confirmation: 'password', role: 'editor',
      name: 'John Editor2' },
    { email: 'editor3@example.com', password: 'password', password_confirmation: 'password', role: 'editor',
      name: 'John Editor3' },
    { email: 'admin@example.com', password: 'password', password_confirmation: 'password', role: 'admin',
      name: 'John Admin' }
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
    { name: 'sports' },
    { name: 'general' }
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
    { title: 'US house rules', content: 'Branches of Government', category_id: category_ids[0],
      user_id: editors[0].id },
    { title: 'PickleBall', content: 'The new Short Tennis', category_id: category_ids[1], user_id: editors[0].id },
    { title: 'Tip of the day', content: 'General Information', category_id: category_ids[2], user_id: editors[0].id },
    { title: 'Elections in Senate', content: 'Mid Term Elections', category_id: category_ids[0],
      user_id: editors[1].id },
    { title: 'March Madness', content: 'NCAA Tournament', category_id: category_ids[1], user_id: editors[1].id },
    { title: 'Daily Routine', content: 'General Information', category_id: category_ids[2], user_id: editors[1].id },
    { title: 'Governor Races', content: 'Elections', category_id: category_ids[0], user_id: editors[2].id },
    { title: 'Baseball starts', content: 'MLB in covid times', category_id: category_ids[1], user_id: editors[2].id },
    { title: 'Online shopping', content: 'General Information', category_id: category_ids[2], user_id: editors[2].id },
    { title: 'NBA 2022 Contenders', content: 'Basketball in Fall', category_id: category_ids[1],
      user_id: editors[2].id }
  ]

  Article.create(articles)

  puts "#{Article.count} articles created"
end

ApplicationRecord.transaction do
  create_users
  create_categories
  create_articles
end
