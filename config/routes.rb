Rails.application.routes.draw do

  root to: 'stocks#index'

  devise_for :users

  resources :stocks do
    member do
      get :test
    end
  end

  resources :positions

  post '/data/refresh', to: 'data#refresh', as: 'data_refresh_url'

end
