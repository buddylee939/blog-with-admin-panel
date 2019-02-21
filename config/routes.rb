Rails.application.routes.draw do

  get '/login' => 'admin/sessions#new'
  get '/logout' => 'admin/sessions#destroy'
  
  root 'admin/moderators#index'
  namespace :admin do
    resources :posts
    resources :tags, except: [:index]
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end
  # resources :moderators, module: 'admin'

end
