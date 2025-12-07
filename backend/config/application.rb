require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Zarbin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be configured before using any Rabbit consumer instances
    # config.eager_load_paths += %W(#{config.root}/extras)

    # Only load the configurations from the `config/environments/` directory.
    config.eager_load_paths += Dir[Rails.root.join("app", "services")]
    config.eager_load_paths += Dir[Rails.root.join("app", "jobs")]

    # Timezone configuration
    config.time_zone = "Asia/Tehran"
    config.active_record.default_timezone = :utc

    # i18n configuration
    config.i18n.default_locale = :fa
    config.i18n.available_locales = [:fa, :en]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    # API-only mode
    config.api_only = true

    # Generate UUIDs for models (optional)
    # config.generators do |g|
    #   g.orm :active_record, primary_key_type: :uuid
    # end

    # Solid Queue configuration
    config.solid_queue.silence_polling = true
  end
end
