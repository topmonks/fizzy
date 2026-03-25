if Rails.env.production? && ENV["SENTRY_DSN"].present?
  Sentry.init do |config|
    config.dsn = ENV["SENTRY_DSN"]
    config.breadcrumbs_logger = %i[ active_support_logger http_logger ]
    config.send_default_pii = false
    config.excluded_exceptions += [ "ActiveRecord::ConcurrentMigrationError" ]
    config.rails.register_error_subscriber = true
  end
end
