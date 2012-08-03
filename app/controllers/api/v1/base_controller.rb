module Api
  module V1
    class BaseController < Api::BaseController
      def api_version
        '1'
      end
    end
  end
end
