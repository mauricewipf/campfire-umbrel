Rails.application.config.after_initialize do
  %w[ db files ].each do |dir|
    path = Rails.root.join("storage", dir)
    path.mkpath unless path.exist?
  rescue Errno::EACCES => e
    # This should never happen if Dockerfile pre-created directories correctly
    Rails.logger.error "Storage directory #{path} not writable: #{e.message}"
    # Fail fast in non-production environments to catch configuration issues
    raise unless Rails.env.production?
  end
end
