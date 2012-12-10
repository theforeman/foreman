module Api
  module V2
    class BaseController < Api::BaseController
      def api_version
        '2'
      end
    end
  end
end
