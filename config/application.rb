require_relative 'boot'

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
require "sprockets/railtie"

Bundler.require(*Rails.groups)

module LineBot
  class Application < Rails::Application
    config.load_defaults 5.2
    
    # タイムゾーンの設定
    config.time_zone = 'Tokyo'
    config.i18n.default_local = :ja
    config.generators.system_tests = nil
  end
end
