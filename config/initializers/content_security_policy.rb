# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
# end
#
## config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
    if Rails.env.development?
    # Development: allow inline scripts (unsafe!)
    policy.script_src :self,
                      :unsafe_inline,
                      "https://www.google.com",
                      "https://www.gstatic.com",
                      "https://ga.jspm.io"
    else
  # allow self and reCAPTCHA
  policy.script_src :self,
                    "https://www.google.com",
                    "https://www.gstatic.com",
                      "https://ga.jspm.io",
                    # this lambda injects 'nonce-<random>' into the policy
                    -> { "'nonce-#{content_security_policy_nonce}'" }
    end

  policy.frame_src  :self, "https://www.google.com"
  # ... any other directives you need ...
end
unless Rails.env.development?
# Tell Rails how to generate the nonces:
Rails.application.config.content_security_policy_nonce_generator = ->(request) do
  SecureRandom.base64(16)
end

# Tell Rails which directives get a nonce:
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]
end
