Rails.application.routes.draw do
  namespace :editor do
    get 'my_articles/index'
  end
  namespace :admin do
    resources :users, except: :destroy
    post 'archive_article/:article_id' => 'archive_articles#create', as: :archive_article
    post 'archive_user/:user_id' => 'archive_users#create', as: :archive_user
  end

  devise_for :users, skip: :registrations
  devise_scope :user do
    resource :registration,
             only: [:new, :create, :edit, :update],
             path: 'users',
             path_names: { new: 'sign_up' },
             controller: 'devise/registrations',
             as: :user_registration do
      get :cancel
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'articles#index'
  resources :articles
end
