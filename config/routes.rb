Rails.application.routes.draw do

  root to: 'stocks#index'

  devise_for :users

  resources :stocks do
    member do
      get :test
    end
    collection do
      post :refresh
    end
  end

  resources :positions

end
