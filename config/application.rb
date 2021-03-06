require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PgSerializerTest
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.cache_store = :null_store
    config.eager_load = true
    config.load_defaults 5.2

    config.autoload_paths << Rails.root.join("app/services")
  end
end
