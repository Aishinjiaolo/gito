CarrierWave.configure do |config|
  config.fog_credentials = {
      :provider               => 'AWS',
      :aws_access_key_id      => 'AKIAIOYN55BWLL2PTEGQ',
      :aws_secret_access_key  => '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',
      :region                 => 'us-west-2'
  }
  config.fog_directory  = 'gito_user_repo'
  config.fog_public     = false

  config.validate_unique_filename = false
  # see https://github.com/jnicklas/carrierwave#using-amazon-s3
  # for more optional configuration
end
