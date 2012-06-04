class ErrorsController < ApplicationController
  def routing
    path = params[:a]
    if path =~ /puppet\/rdoc\/([^\/]+)\/classes\/(.+?)\.html/
      render :template => "puppetclasses/no_route", :locals => {:environment => $1, :name => $2.gsub("/","::")}, :layout => false
    else
      render 'common/404'
    end
  end
end