class ReactController < ApplicationController
  layout 'layouts/react_application'
end

def index
  render 'react/index'
end
