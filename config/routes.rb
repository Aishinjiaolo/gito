Gito::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path => 'users'

  resources :users do
      resources :sheets
  end

  root :to => 'high_voltage/pages#show', :id => 'home'
end
