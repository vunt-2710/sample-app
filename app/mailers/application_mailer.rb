class ApplicationMailer < ActionMailer::Base
  default from: Settings.default.email.fromEmail
  layout "mailer"
end
