Rails.application.routes.draw do
  get "home/index"

  resource :session, only: %i[new create destroy]
  resources :users
  resources :password_resets

  get "signup", to: "users#new"
  delete "logout", to: "sessions#destroy", as: :logout
  get    "login",  to: "sessions#new"
  get "/users/login_status", to: "users#login_status"


  resources :posts
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
  #


  resources :domain_crawlers do
    collection do
      get  :set_header, :display_group, :delete_result
      post :search, :add_result, :remove_group_result
      get  :group_action, :expand_contract_action, :domain_action,
         :more_results, :process_more_results, :previous_search, :tidy_up
    end
  end

  root "users#index"
end
