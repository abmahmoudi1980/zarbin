# CORS Configuration for Flutter Client
# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*" # In production, specify allowed origins explicitly
    resource "*",
             headers: :any,
             methods: [:get, :post, :put, :patch, :delete, :options],
             credentials: true,
             max_age: 86400
  end
end
