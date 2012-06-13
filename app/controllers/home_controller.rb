class HomeController < ApplicationController
  def index
    redirect_to "/projects/default"
  end

end
