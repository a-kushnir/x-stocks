Rails.application.routes.draw do

  root to: 'home#index'

  devise_for :users, controllers: {registrations: 'registrations'}

  resources :stocks, except: [:edit, :update], id: /.*/
  resources :positions, only: [:index, :update]
  resources :dividends, only: [:index]

  resources :services, only: [:index, :update] do
    member do
      get :run
      get :log
      get :error
    end
  end

  post '/data/refresh', to: 'data#refresh', as: 'data_refresh_url'

  match '*path', to: 'application#not_found', via: :all

end
