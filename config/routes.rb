Rails.application.routes.draw do

  root to: 'home#index'

  devise_for :users

  resources :stocks, except: [:edit, :update]
  resources :positions, only: [:index, :update]
  resources :dividends, only: [:index]
  resources :services, only: [:index, :update]

  post '/data/refresh', to: 'data#refresh', as: 'data_refresh_url'

end
