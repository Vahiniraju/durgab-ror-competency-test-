class UserService
  def build_user(user_params)
    user = User.new(user_params)
    user.set_password
    user.skip_confirmation!
    user
  end

  def password_instructions(email)
    Devise::UserMailer.reset_password_instructions(email).deliver_now
  end
end
