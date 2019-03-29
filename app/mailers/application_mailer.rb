class ApplicationMailer < ActionMailer::Base
  default from: ENV["DEFAULT_FROM_ADDRESS_FOR_EMAILS_SENT"]
  layout 'mailer'
end
