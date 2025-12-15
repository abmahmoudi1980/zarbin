# frozen_string_literal: true

module Api
  module V1
    class CategoriesController < ApplicationController
      before_action :set_category, only: [:show]

      # GET /api/v1/categories
      def index
        categories = Category.ordered
        render json: format_categories(categories)
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # GET /api/v1/categories/:id
      def show
        render json: format_category(@category)
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      # POST /api/v1/categories/seed
      def seed
        Category.find_or_create_defaults
        categories = Category.ordered
        render json: {
          message: "Categories seeded successfully",
          categories: format_categories(categories)
        }, status: :created
      rescue StandardError => e
        render json: { error: e.message }, status: :internal_server_error
      end

      private

      def set_category
        @category = Category.find(params[:id])
      end

      def format_category(category)
        {
          id: category.id,
          persian_name: category.persian_name,
          icon_code: category.icon_code,
          display_order: category.display_order,
          transaction_count: category.transactions.count
        }
      end

      def format_categories(categories)
        {
          categories: categories.map { |c| format_category(c) },
          total: categories.count
        }
      end
    end
  end
end
