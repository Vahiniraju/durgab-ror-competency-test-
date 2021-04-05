class Admin::UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  access admin: %i[index show new create edit update]

  def index
    @users = User.all
  end

  def show
    @articles = @user.unscoped_articles
  end

  def new
    @user = User.new
  end

  def create
    @user = UserService.new.build_user(user_params)
    if @user.save
      SetPasswordMailer.send_email(@user).deliver_now
      redirect_to admin_user_path(@user), success: 'User Account Created.'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), success: 'User Account Updated.'
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :roles, :name)
  end

  def set_user
    @user = User.find params[:id]
  end
end
