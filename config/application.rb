# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_mailbox/engine'
require 'action_text/engine'
require 'action_view/railtie'
require 'action_cable/engine'
# require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module XStocks
  # Primary xStocks Application configuration
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.eager_load_paths << Rails.root.join('lib')

    # Auto-load API and its subdirectories
    config.paths.add 'app/api', glob: '**/*.rb'
    config.autoload_paths += Dir["#{Rails.root}/app/api/*"]

    # The SameSite attribute of the Set-Cookie HTTP response header allows you to declare if your cookie should be restricted to a first-party or same-site context.
    # Lax: Cookies are not sent on normal cross-site sub-requests (for example to load images or frames into a third party site), but are sent when a user is navigating to the origin site (i.e., when following a link).
    # Strict: Cookies will only be sent in a first-party context and not be sent along with requests initiated by third party websites.
    # None: Cookies will be sent in all contexts, i.e. in responses to both first-party and cross-origin requests. If SameSite=None is set, the cookie Secure attribute must also be set (or the cookie will be blocked).
    config.action_dispatch.cookies_same_site_protection = 'Strict'
  end
end
