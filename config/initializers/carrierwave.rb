CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'],
      :region                 => 'us-west-2'
  }
  config.fog_directory  = 'gito_user_repo'
  config.fog_public     = false

  config.validate_unique_filename = false
  # see https://github.com/jnicklas/carrierwave#using-amazon-s3
  # for more optional configuration
end
