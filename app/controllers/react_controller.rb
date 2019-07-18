class ReactController < ApplicationController
  layout 'layouts/react_application'
  skip_before_action :authorize, :only => :index

  def index
    render 'react/index'
  end
end
