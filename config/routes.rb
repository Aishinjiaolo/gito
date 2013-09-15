Gito::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path => 'users'

  resources :users do
    resources :sheets do
      get   'upload', on: :member
      get   'load',   on: :member
      post  'save',   on: :member
      get   'upload_s3', on: :member
    end
  end

  root :to => 'high_voltage/pages#show', :id => 'home'
end
