class ReactController < ApplicationController
  layout 'layouts/react_application'

  def index
    render 'react/index'
  end
end
