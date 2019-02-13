Rails.application.configure do

  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  config.action_mailer.raise_delivery_errors = false
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.debug = true
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
  config.action_mailer.delivery_method = :mailjet_api
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.perform_deliveries = false

  config.assets.digest = true
  config.assets.raise_runtime_errors = true
  config.serve_static_files = true

  config.react.variant  = :development
  config.react.addons = true

  config.action_dispatch.default_headers = {
      'X-Frame-Options' => 'ALLOWALL'
  }

end
