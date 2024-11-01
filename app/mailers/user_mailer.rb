class UserMailer < ApplicationMailer
  def account_activation user
    @user = user
    mail to: user.email, subject: t("mail.activateAccount.subject")
  end

  def password_reset user
    @user = user
    mail to: user.email, subject: t("mail.resetPass.subject")
  end
end
