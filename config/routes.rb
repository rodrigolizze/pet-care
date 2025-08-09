Rails.application.routes.draw do
  # get 'users/show'
  devise_for :users, sign_out_via: [:delete, :get]
  root to: "pages#home"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: :show do  # Add this to enable user profile pages
    collection do
      get  "become_sitter", to: "users#become_sitter"    # form page
      post "become_sitter", to: "users#activate_sitter"  # submission
      get "sitter", to: "users#sitter_dashboard"
    end
  end

  resources :availabilities, only: [:index, :new, :create, :destroy] do
    resources :bookings, only: [:new, :create, :destroy]
  end
  
  resources :bookings, only: [:index]   # /bookings (Minhas Reservas)

  get "bookings/available_dates", to: "bookings#available_dates", as: :available_dates


  # Defines the root path route ("/")
  # root "posts#index"
end
