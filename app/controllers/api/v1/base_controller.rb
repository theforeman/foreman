module Api
  module V1
    class BaseController < Api::BaseController
      respond_to :json
    end
  end
end
