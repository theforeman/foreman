module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2

      resource_description do
        resource_id "v2_base" # to avoid conflicts with V1::BaseController
        api_version "v2"
      end

      before_filter :root_node_name, :only => :index
      before_render :get_metadata, :only => :index
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

      def get_metadata
        @results ||= instance_variable_get("@#{controller_name}")
        #@total should be defined in individual controllers, but in case it's not.
        @total ||= @results.try(:count).to_i
        if (@search = params[:search]).present?
          @subtotal = @results.try(:count).to_i
        else
          @subtotal = @total
        end

        if params[:order].present? && (order_array = params[:order].split(' ')).any?
          @by = order_array[0]
          @order   = order_array[1]
          @order ||= 'ASC'
        end

        @per_page = params[:per_page].present? ? params[:per_page].to_i : Setting::General.entries_per_page

        if params[:page].present?
          @page = params[:page].to_i
        else
          @page = 1
        end

      end

    end
  end
end
