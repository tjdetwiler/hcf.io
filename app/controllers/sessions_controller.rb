class SessionsController < ApplicationController

  def login
    if request.post?
      p params
      if session[:user] = User.authenticate(params[:login], params[:password])
        p "good" 
        flash[:message]  = "Login successful"
        redirect_to params[:src]
      else
        p "bad"
        redirect_to params[:src]
      end
    end
  end

  def logout
    session[:user] = nil
    redirect_to "/"
  end
end
