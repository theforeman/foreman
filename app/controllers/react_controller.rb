class ReactController < ApplicationController
  layout 'layouts/react_application'
  skip_before_action :authorize, :only => :index

  def index
    response.headers['X-Request-Path'] = request.path
    render 'react/index'
  end
end
