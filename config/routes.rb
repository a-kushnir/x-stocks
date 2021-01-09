# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  mount API::Root => '/api'

  devise_for :users, controllers: { registrations: 'registrations' }
  devise_scope :user do
    post '/registrations/regenerate' => 'registrations#regenerate'
  end

  resources :stocks, except: %i[edit update], id: /.*/
  resources :positions, only: %i[index update]
  resources :dividends, only: [:index]

  resources :services, only: [:index] do
    member do
      get :run, to: 'services#run_one'
      get :log
      get :error
    end
    collection do
      get :run, to: 'services#run_all'
    end
  end

  post '/data/refresh', to: 'data#refresh', as: 'data_refresh_url'

  match '*path', to: 'application#not_found', via: :all
end
