Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  namespace :admin do
    root to: "dashboard#index"
    resources :usuarios
  end

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
