Rails.application.routes.draw do
  namespace :admin do
    resources :users, except: :destroy
    post 'archive_article/:article_id' => 'archive_articles#create', as: :archive_article
    post 'archive_user/:user_id' => 'archive_users#create', as: :archive_user
  end

  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'articles#index'
  resources :articles
end
