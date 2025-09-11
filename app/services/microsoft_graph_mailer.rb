class MicrosoftGraphMailer
  include HTTParty
  base_uri 'https://graph.microsoft.com/v1.0'

  def initialize
    @tenant_id = ENV['MICROSOFT_TENANT_ID']
    @client_id = ENV['MICROSOFT_CLIENT_ID'] 
    @client_secret = ENV['MICROSOFT_CLIENT_SECRET']
    @sender_email = ENV['MICROSOFT_SENDER_EMAIL']
    
    validate_configuration
  end

  def send_email(to:, subject:, body:, body_type: 'HTML')
    access_token = get_access_token
    
    email_data = {
      message: {
        subject: subject,
        body: {
          contentType: body_type,
          content: body
        },
        toRecipients: [
          {
            emailAddress: {
              address: to
            }
          }
        ]
      }
    }

    response = self.class.post(
      "/users/#{@sender_email}/sendMail",
      headers: {
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json'
      },
      body: email_data.to_json
    )

    if response.success?
      Rails.logger.info "Email sent successfully via Microsoft Graph to #{to}"
      true
    else
      error_message = "Microsoft Graph email failed: #{response.code} - #{response.body}"
      Rails.logger.error error_message
      raise EmailDeliveryError.new(error_message)
    end
  end

  private

  def get_access_token
    token_url = "https://login.microsoftonline.com/#{@tenant_id}/oauth2/v2.0/token"
    
    response = HTTParty.post(token_url, {
      body: {
        grant_type: 'client_credentials',
        client_id: @client_id,
        client_secret: @client_secret,
        scope: 'https://graph.microsoft.com/.default'
      },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    })

    if response.success?
      response.parsed_response['access_token']
    else
      error_message = "Failed to get Microsoft Graph access token: #{response.code} - #{response.body}"
      Rails.logger.error error_message
      raise EmailDeliveryError.new(error_message)
    end
  end

  def validate_configuration
    missing_vars = []
    missing_vars << 'MICROSOFT_TENANT_ID' if @tenant_id.blank?
    missing_vars << 'MICROSOFT_CLIENT_ID' if @client_id.blank?
    missing_vars << 'MICROSOFT_CLIENT_SECRET' if @client_secret.blank?
    missing_vars << 'MICROSOFT_SENDER_EMAIL' if @sender_email.blank?

    unless missing_vars.empty?
      raise EmailDeliveryError.new("Missing Microsoft Graph configuration: #{missing_vars.join(', ')}")
    end
  end
end

class EmailDeliveryError < StandardError; end
