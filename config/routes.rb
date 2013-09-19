Gito::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path => 'users'

  resources :users do
    resources :sheets do
      get   'history',   on: :member
      get   'upload',    on: :member
      get   'pull',      on: :member
      get   'load_data', on: :member
      post  'save_data', on: :member
    end
  end

  root :to => 'high_voltage/pages#show', :id => 'home'
end
