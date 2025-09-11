namespace :email do
  desc "Test Microsoft Graph email sending"
  task test_graph: :environment do
    puts "Testing Microsoft Graph email configuration..."
    
    begin
      # Test configuration
      mailer = MicrosoftGraphMailer.new
      puts "✓ Microsoft Graph configuration is valid"
      
      # Test with a dummy user (you should replace this email with a real test email)
      test_email = ENV['TEST_EMAIL'] || 'test@yourdomain.com'
      
      mailer.send_email(
        to: test_email,
        subject: 'Test Email from Microsoft Graph',
        body: '<h1>Test Email</h1><p>This is a test email sent via Microsoft Graph.</p>'
      )
      
      puts "✓ Test email sent successfully to #{test_email}"
      
    rescue EmailDeliveryError => e
      puts "✗ Email test failed: #{e.message}"
      puts "Please check your Microsoft Graph configuration in .env file:"
      puts "- MICROSOFT_TENANT_ID"
      puts "- MICROSOFT_CLIENT_ID" 
      puts "- MICROSOFT_CLIENT_SECRET"
      puts "- MICROSOFT_SENDER_EMAIL"
    rescue => e
      puts "✗ Unexpected error: #{e.message}"
    end
  end
end
