class ApplicationController < ActionController::Base
  add_flash_types :success

  before_action :authenticate_user!
end
