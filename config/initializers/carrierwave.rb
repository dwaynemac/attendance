if Rails.env.test? or Rails.env.cucumber? or Rails.env.development?

  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = true
  end

else

  CarrierWave.configure do |config|
    config.cache_dir = "#{Rails.root}/tmp/uploads"
    #config.storage = :fog
    if Rails.env.production?
      config.fog_credentials = {
          :provider               => 'AWS',
          :aws_access_key_id      => ENV['S3_KEY_ID'],
          :aws_secret_access_key  => ENV['S3_SECRET_KEY'],
      }
      config.fog_directory  = 'attendance-staging'
      config.asset_host       = "http://attendance-staging.s3.amazonaws.com"
      #config.fog_directory = 'padma-attendance-production',
      #config.asset_host = 'http://padma-attendance-production.s3.amazonaws.com'
    else
    config.cache_dir = "#{Rails.root}/tmp/uploads"
    config.storage = :fog
      config.fog_credentials = {
          :provider               => 'AWS',
          :aws_access_key_id      => ENV['S3_KEY_ID'],
          :aws_secret_access_key  => ENV['S3_SECRET_KEY'],
      }
      config.fog_directory  = 'attendance-staging'
      config.asset_host       = "http://attendance-staging.s3.amazonaws.com"
    end
    #config.fog_public     = false
  end

end
