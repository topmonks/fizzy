if Rails.env.production?
  Sentry.init do |config|
    config.dsn = "https://e4fbb30f10b77310bbfac4eae4afd74b@o4510708126056448.ingest.de.sentry.io/4511104128712784"
    config.breadcrumbs_logger = %i[ active_support_logger http_logger ]
    config.send_default_pii = false
    config.excluded_exceptions += [ "ActiveRecord::ConcurrentMigrationError" ]
    config.rails.register_error_subscriber = true
  end
end
