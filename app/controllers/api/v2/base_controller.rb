module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2

      resource_description do
        api_version "v2"
        app_info "Foreman v2 is currently in development and is not the default version. You may use v2 by either passing 'version=2' in the Accept Header or entering api/v2/ in the URL."
      end

      before_filter :root_node_name, :only => :index
      before_render :get_metadata, :only => :index
      before_filter :setup_has_many_params, :only => [:create, :update]
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
          @subtotal ||= @results.try(:count).to_i
        else
          @subtotal ||= @total
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

      def setup_has_many_params
        params.each do |k,v|
          if v.kind_of?(Array)
            magic_method_ids = "#{k.singularize}_ids"
            magic_method_names = "#{k.singularize}_names"
            if resource_class.instance_methods.map(&:to_s).include?(magic_method_ids) && v.any? && v.all? { |a| a.keys.include?("id") }
              params[controller_name.singularize][magic_method_ids] = v.map { |a| a["id"] }
            elsif resource_class.instance_methods.map(&:to_s).include?(magic_method_names) && v.any? && v.all? { |a| a.keys.include?("name") }
              params[controller_name.singularize][magic_method_names] = v.map { |a| a["name"] }
            end
          end
        end
      end

    end
  end
end
