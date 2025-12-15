# Rails Routes Configuration
# frozen_string_literal: true

Rails.application.routes.draw do
  # API v1 routes
  namespace :api do
    namespace :v1 do
      # Health check
      get '/health', to: 'health#check'

      # Authentication endpoints
      post '/auth/register', to: 'auth#register'
      post '/auth/verify-otp', to: 'auth#verify_otp'
      post '/auth/login', to: 'auth#login'
      post '/auth/refresh', to: 'auth#refresh'

      # Market rates (public)
      get '/rates', to: 'rates#index'
      get '/rates/history', to: 'rates#history'

      # Protected routes (require authentication)
      resources :transactions, only: [:create, :index, :show, :update, :destroy]
      get '/balance', to: 'balance#show'
      get '/categories', to: 'categories#index'
      get '/dashboard', to: 'dashboard#show'
      get '/dashboard/spending-breakdown', to: 'dashboard#spending_breakdown'
    end
  end

  # Root route
  root 'pages#welcome'
end
