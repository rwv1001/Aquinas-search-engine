class GraphUserMailer
  def self.password_reset(user)
    mailer = MicrosoftGraphMailer.new
    
    # Create the email body HTML directly for now
    # You can later create a proper template system if needed
    email_body = build_password_reset_email(user)
    
    # Send via Microsoft Graph
    mailer.send_email(
      to: user.email,
      subject: 'Password Reset',
      body: email_body,
      body_type: 'HTML'
    )
  rescue EmailDeliveryError => e
    Rails.logger.error "Password reset email failed: #{e.message}"
    raise e
  end

  private

  def self.build_password_reset_email(user)
    # Get the default URL options from ActionMailer configuration
    default_options = Rails.application.config.action_mailer.default_url_options || {}
    
    # Build URL options based on environment
    url_options = {
      host: default_options[:host] || 'localhost'
    }
    
    # Only include port if we're in development or if explicitly set
    if Rails.env.development? && default_options[:port]
      url_options[:port] = default_options[:port]
    end
    
    reset_url = Rails.application.routes.url_helpers.edit_password_reset_url(
      user.password_reset_token, 
      url_options
    )

    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <title>Password Reset</title>
        </head>
        <body>
          <h2>Password Reset Request</h2>
          <p>Hello,</p>
          <p>Someone has requested a link to change your password. You can do this through the link below.</p>
          <p><a href="#{reset_url}">Change my password</a></p>
          <p>If you didn't request this, please ignore this email.</p>
          <p>Your password won't change until you access the link above and create a new one.</p>
        </body>
      </html>
    HTML
  end
end
