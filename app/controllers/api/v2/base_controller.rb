module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2
    end
  end
end
