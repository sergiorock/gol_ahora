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
    resources :reservations, only: %i[index show edit update] do
      member { get :pdf }
    end
    resources :charges
    resource :walkin, only: %i[new create], controller: "walkins"
    resources :discounts do
      member { patch :toggle }
    end
    resources :receipts do
      member { get :pdf }
    end
  end

  resource :profile, only: [:show, :edit, :update]

  resources :courts, only: [:index, :show] do
    member { get :availability }
  end

  resources :reservations, only: %i[index new create show] do
    member { delete :cancel }
  end

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
