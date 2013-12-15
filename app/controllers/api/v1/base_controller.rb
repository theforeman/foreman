module Api
  module V1
    class BaseController < Api::BaseController
      include Api::Version1

      resource_description do
        api_version "v1"
        app_info "Foreman v1 is currently the default API version."
      end
    end
  end
end
