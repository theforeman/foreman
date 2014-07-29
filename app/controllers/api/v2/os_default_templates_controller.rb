module Api
  module V2
    class OsDefaultTemplatesController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      wrap_parameters :os_default_template, :include => OsDefaultTemplate.attribute_names

      before_filter :find_required_nested_object
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, '/operatingsystems/:operatingsystem_id/os_default_templates', 'List os default templates for operating system'
      param :operatingsystem_id, String, :desc => 'id of operating system'
      param :page, String, :desc => 'paginate results'
      param :per_page, String, :desc => 'number of entries per request'

      def index
        @os_default_templates = nested_obj.os_default_templates.paginate(paginate_options)
        @total = nested_obj.os_default_templates.count
      end

      api :GET, '/operatingsystems/:operatingsystem_id/os_default_templates/:id', 'Show a os default template kind for operating system'
      param :operatingsystem_id, String, :desc => 'id of operating system'
      param :id, :number, :required => true

      def show
      end

      def_param_group :os_default_template do
        param :template_kind_id, :number
        param :config_template_id, :number
      end

      api :POST, '/operatingsystems/:operatingsystem_id/os_default_templates/', 'Create a os default template for operating system'
      param :operatingsystem_id, String, :desc => 'id of operating system'
      param_group :os_default_template, :as => :create

      def create
        @os_default_template = nested_obj.os_default_templates.new(params[:os_default_template])
        process_response @os_default_template.save
      end

      api :PUT, '/operatingsystems/:operatingsystem_id/os_default_templates/:id', 'Update a os default template for operating system'
      param :operatingsystem_id, String, :desc => 'id of operating system'
      param :id, String, :required => true
      param_group :os_default_template

      def update
        process_response @os_default_template.update_attributes(params[:os_default_template])
      end

      api :DELETE, '/operatingsystems/:operatingsystem_id/os_default_templates/:id', 'Delete a os default template for operating system'
      param :operatingsystem_id, String, :desc => 'id of operating system'
      param :id, String, :required => true

      def destroy
        process_response @os_default_template.destroy
      end

      private

      def allowed_nested_id
        %w(operatingsystem_id)
      end

    end
  end
end
