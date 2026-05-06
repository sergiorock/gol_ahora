Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  namespace :admin do
    root to: "dashboard#index"
    resources :users
  end

  resource :profile, only: [:show, :edit, :update]

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
