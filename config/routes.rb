Rails.application.routes.draw do
  resources :stocks do
    member do
      get :test
    end
  end
end
