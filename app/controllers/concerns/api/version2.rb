module Api
  module Version2
    extend ActiveSupport::Concern

    included do
      before_filter :root_node_name, :only => :index
      layout 'api/v2/layouts/index_layout', :only => :index
    end

    def api_version
      '2'
    end

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