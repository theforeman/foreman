module Api
  module V1
    class BaseController < Api::BaseController
      include Api::Version1

      resource_description do
        api_version "v1"
        app_info N_("<b>Foreman API v1 is deprecated. Please use v2.</b><br />If you still need to use v1, you may do so by either passing 'version=1' in the Accept Header or using api/v1/ in the URL.")
      end
    end
  end
end
