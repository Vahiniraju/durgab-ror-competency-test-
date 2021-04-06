class Admin::ArchiveUsersController < ApplicationController
  before_action :set_user, only: %i[create]
  access admin: %i[create]

  def create
    if @user.update(archived: true)
      redirect_to admin_user_path(@user), success: 'User archived along with their articles.'
    else
      redirect_to admin_user_path(@user), alert: 'Could not archive user.'
    end
  end

  def set_user
    @user = User.find_by_id params[:user_id]
    return redirect_to admin_users_path, alert: 'User not found.' unless @user
    return redirect_to admin_user_path(@user), alert: 'User is already archived.' if @user.archived
  end
end
