module Admin::UsersHelper
  def options_for_roles(user)
    role = user.role if user.id
    options_for_select(User::ROLES.map { |role| [role.to_s, role.to_s] }, selected: role)
  end
end
