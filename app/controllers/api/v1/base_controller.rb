module Api
  module V1
    class BaseController < Api::BaseController
      include Api::Version1

      resource_description do
        api_version "v1"
        app_info "Foreman v1 is currently the default API version. Users are recommended to use API v2 as future versions of Foreman will change the default to v2 and then deprecate and/or remove v1. You may explicitly use v1 by either passing 'version=1' in the Accept Header or using api/v1/ in the URL."
      end
    end
  end
end
