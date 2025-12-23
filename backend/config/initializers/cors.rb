# CORS Configuration for Flutter Client
# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # In development, allow localhost origins
    # In production, specify your actual domains
    origins ENV.fetch("CORS_ORIGINS", "http://localhost:3000,http://localhost:8080,http://0.0.0.0:8080").split(",")
    
    resource "*",
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options],
             credentials: true,
             max_age: 86400
  end
end
