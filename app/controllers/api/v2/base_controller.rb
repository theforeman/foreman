module Api
  module V2
    class BaseController < Api::BaseController
      include Api::Version2

      resource_description do
        api_version "v2"
        app_info "Foreman v2 is currently in development and is not the default version. You may use v2 by either passing 'version=2' in the Accept Header or entering api/v2/ in the URL."
      end

      before_filter :setup_has_many_params, :only => [:create, :update]
      # ensure include_root_in_json = false for V2 only
      around_filter :disable_json_root

      layout 'api/v2/layouts/index_layout', :only => :index

      helper_method :root_node_name, :metadata_total, :metadata_subtotal, :metadata_search,
                    :metadata_order, :metadata_by, :metadata_page, :metadata_per_page

      def root_node_name
        @root_node_name ||= if Rabl.configuration.use_controller_name_as_json_root
                              controller_name.split('/').last
                            elsif params['root_name'].present?
                              params['root_name']
                            else
                              Rabl.configuration.json_root_default_name
                            end
      end

      def metadata_total
        @total ||= resource_scope.try(:count).to_i
      end

      def metadata_subtotal
        if params[:search].present?
          @subtotal ||= instance_variable_get("@#{controller_name}").try(:count).to_i
        else
          @subtotal ||= metadata_total
        end
      end

      def metadata_search
        @search ||= params[:search]
      end

      def metadata_order
        @order ||=  params[:order].present? && (order_array = params[:order].split(' ')).any? ? (order_array[1] || 'ASC') : nil
      end

      def metadata_by
        @by ||= params[:order].present? && (order_array = params[:order].split(' ')).any? ? order_array[0] : nil
      end

      def metadata_page
        @page ||= params[:page].present? ? params[:page].to_i : 1
      end

      def metadata_per_page
        @per_page ||= params[:per_page].present? ? params[:per_page].to_i : Setting::General.entries_per_page
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

      def render_error(error, options = { })
        render options.merge(:template => "api/v2/errors/#{error}",
                             :layout   => 'api/v2/layouts/error_layout')
      end

      private

      def disable_json_root
        # disable json root element
        ActiveRecord::Base.include_root_in_json = false
        yield
      ensure
        # re-enable json root element
        ActiveRecord::Base.include_root_in_json = true
      end

    end
  end
end
