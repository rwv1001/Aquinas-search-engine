Recaptcha.configure do |config|
  if Rails.env.development?
    # Use Google's test keys for development - these always pass and work with localhost
    config.site_key  = "6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI"
    config.secret_key = "6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe"
  else
    # Use production keys for production
    config.site_key  = ENV["RECAPTCHA_SITE_KEY"]
    config.secret_key = ENV["RECAPTCHA_SECRET_KEY"]
  end
end
