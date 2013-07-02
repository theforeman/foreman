module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2

      resource_description do
        resource_id "v2_base" # to avoid conflicts with V1::BaseController
        api_version "v2"
      end
    end
  end
end
