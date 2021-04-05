Rails.application.routes.draw do
  namespace :admin do
    resources :users, except: :destroy
  end

  devise_for :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'articles#index'
  resources :articles
end
