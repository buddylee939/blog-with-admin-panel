Rails.application.routes.draw do

  get '/login' => 'admin/sessions#new'
  get '/logout' => 'admin/sessions#destroy'
  
  root 'posts#index'
  namespace :admin do
    resources :posts
    resources :settings, only: [:new, :edit, :update, :create]
    resources :dashboard, only: [:index]
    resources :notifications, only: [:index, :destroy]
    resources :messages, only: [:index, :show, :update, :destroy]
    resources :visitors, only: [:index, :destroy]
    resources :comments, only: [:index, :update, :destroy]
    resources :tags, except: [:index]
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end
  # resources :moderators, module: 'admin'
  
  resources :posts, only: [:index, :show]
  resources :messages, only: [:new, :create]
  resources :comments, only: [:create]

  match 'dismiss_all_notifications', to: 'admin/notifications#delete_all', via: :delete
end
