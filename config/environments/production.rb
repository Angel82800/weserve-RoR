Rails.application.configure do

  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.assets.js_compressor = :uglifier
  config.assets.compile = true
  config.assets.digest = true
  config.serve_static_files = true
  config.log_level = :debug
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify
  config.log_formatter = ::Logger::Formatter.new
  config.consider_all_requests_local = ENV['consider_all_requests_local'] || false
  config.action_mailer.default_url_options = { :host => ENV["default_url"] }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true

  config.active_record.dump_schema_after_migration = false

  config.react.variant = :production
  config.react.addons = true

  # https://devcenter.heroku.com/articles/logging#writing-to-your-log
  config.logger = Logger.new(STDOUT)

  config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL'
  }

end
