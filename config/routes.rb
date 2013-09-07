Gito::Application.routes.draw do
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }, :path => 'users'

  resource :user do
      resource :spreadsheets
  end

  root :to => 'high_voltage/pages#show', :id => 'home'
end
