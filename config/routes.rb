Rails.application.routes.draw do

  get '/login' => 'admin/sessions#new'
  get '/logout' => 'admin/sessions#destroy'
  # resources :moderators, module: 'admin'
  
  namespace :admin do
    resources :posts
    resources :sessions, only: [:new, :create, :destroy]
    resources :moderators, only: [:index, :edit, :update]
  end

end
