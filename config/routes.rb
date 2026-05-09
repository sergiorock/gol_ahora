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
    resources :leagues do
      resources :matches,     only: %i[new create edit update destroy]
      resources :enrollments, only: %i[index new create edit update destroy]
    end
    resources :tournaments do
      resources :matches,     only: %i[new create edit update destroy]
      resources :enrollments, only: %i[index new create edit update destroy]
    end
    resources :charges
    resource :walkin, only: %i[new create], controller: "walkins"
    resources :discounts do
      member { patch :toggle }
    end
    resources :receipts do
      member { get :pdf }
    end
    resources :personal_deportivos
    resources :clases do
      resources :asistencias, only: %i[create update destroy]
    end
    resources :entrenamientos do
      resources :asistencias, only: %i[create update destroy]
    end
  end

  resource :profile, only: [:show, :edit, :update]

  resources :courts, only: [:index, :show] do
    member { get :availability }
  end

  resources :reservations, only: %i[index new create show] do
    member { delete :cancel }
  end

  resources :leagues, only: %i[index show] do
    resources :enrollments, only: %i[create]
  end
  resources :tournaments, only: %i[index show] do
    resources :enrollments, only: %i[create]
  end
  resources :enrollments, only: %i[index destroy]

  resources :clases, only: %i[index show] do
    resources :asistencias, only: %i[create destroy]
  end
  resources :entrenamientos, only: %i[index show] do
    resources :asistencias, only: %i[create destroy]
  end

  root to: "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end
