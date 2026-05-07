Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  namespace :admin do
    root to: "dashboard#index"
    resources :users do
      member { get :pdf }
    end
    resources :court_types
    resources :courts do
      resources :court_blocks, shallow: true
    end
    resources :reservations, only: %i[index show edit update]
  end

  resource :profile, only: [:show, :edit, :update]

  resources :courts, only: [:index, :show]

  resources :reservations, only: %i[index new create show] do
    member { delete :cancel }
  end

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
