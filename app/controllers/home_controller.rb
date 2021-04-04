class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: :index
  def index
    @current_user = current_user
  end
end