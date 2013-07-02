module Api
  module V1
    class BaseController < Api::BaseController
      include Api::Version1

      resource_description do
        api_version "v1"
        api_version "v2"
      end
    end
  end
end
