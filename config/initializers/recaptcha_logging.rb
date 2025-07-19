Recaptcha.singleton_class.prepend(Module.new do
  # This is the method that actually fires off the HTTP request:
  # Recaptcha.api_verification_free (for v2) or Recaptcha.api_verification_enterprise (for enterprise keys)
  def api_verification_free(verify_hash, timeout:, json:)
    Rails.logger.debug("[Recaptcha] POST #{configuration.verify_url}  payload: #{verify_hash.inspect}")
    super
  end
end)
