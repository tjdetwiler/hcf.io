class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :setup_login_form

  def setup_login_form
    if session[:user] == nil
      puts "Woot"
      @user = User.new
    end
  end
end
