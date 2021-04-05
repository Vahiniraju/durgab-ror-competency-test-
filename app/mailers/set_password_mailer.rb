class SetPasswordMailer < ApplicationMailer
  def send_email(user)
    @user = user
    mail to: @user.email, subject: 'Set Password Instructions'
  end
end
