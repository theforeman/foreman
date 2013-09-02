module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2

      resource_description do
        resource_id "v2_base" # to avoid conflicts with V1::BaseController
        api_version "v2"
      end

      before_filter :root_node_name, :only => :index
      layout 'api/v2/layouts/index_layout', :only => :index

      def root_node_name
        @root_node_name = if Rabl.configuration.use_controller_name_as_json_root
                            controller_name.split('/').last
                          elsif params['root_name'].present?
                            params['root_name']
                          else
                            Rabl.configuration.json_root_default_name
                          end
      end

    end
  end
end
