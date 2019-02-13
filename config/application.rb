require File.expand_path('../boot', __FILE__)

require 'rails/all'
require "firebase_token_generator"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module YouServe
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :fr]
    # config.i18n.available_locales = [:en, :es, :pt]

    config.autoload_paths << Rails.root.join('lib')

    # For Foundation 5
    config.assets.precompile += %w( vendor/modernizr )

    # config.assets.paths << Rails.root.join('app', 'assets', 'fonts')

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.serve_static_files = true

    config.active_record.observers = [
        :team_membership_observer, :project_observer,
        :task_observer, :do_request_observer, :admin_request_observer, :apply_request_observer,
    ]
    config.action_mailer.delivery_method = :mailjet_api
    if Rails.env.production? || Rails.env.staging?
      config.active_job.queue_adapter = :delayed_job
    end
  end
end
