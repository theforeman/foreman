module Api
  module V1
    class BaseController < Api::BaseController
      include Api::Version1
    end
  end
end
