module Api
  module V2
    class OsDefaultTemplatesController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::OsDefaultTemplate

      wrap_parameters OsDefaultTemplate, :include => os_default_template_params_filter.accessible_attributes(parameter_filter_context)

      before_action :find_required_nested_object
      before_action :find_resource, :only => %w{show update destroy}

      api :GET, '/operatingsystems/:operatingsystem_id/os_default_templates', N_('List default templates combinations for an operating system')
      api :GET, '/provisioning_templates/:provisioning_template_id/os_default_templates', N_('List operating systems where this template is set as a default')
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :provisioning_template_id, String, :desc => N_('ID of provisioning template')
      param_group :pagination, ::Api::V2::BaseController

      def index
        @os_default_templates = resource_scope.paginate(paginate_options)
      end

      api :GET, "/operatingsystems/:operatingsystem_id/os_default_templates/:id", N_("Show a default template combination for an operating system")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :id, :number, :required => true

      def show
      end

      def_param_group :os_default_template do
        param :os_default_template, Hash, :required => true, :action_aware => true do
          param :template_kind_id, :number
          param :provisioning_template_id, :number, N_('ID of provisioning template')
        end
      end

      api :POST, "/operatingsystems/:operatingsystem_id/os_default_templates/", N_("Create a default template combination for an operating system")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param_group :os_default_template, :as => :create

      def create
        @os_default_template = nested_obj.os_default_templates.new(os_default_template_params)
        process_response @os_default_template.save
      end

      api :PUT, "/operatingsystems/:operatingsystem_id/os_default_templates/:id", N_("Update a default template combination for an operating system")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :id, String, :required => true
      param_group :os_default_template

      def update
        process_response @os_default_template.update(os_default_template_params)
      end

      api :DELETE, "/operatingsystems/:operatingsystem_id/os_default_templates/:id", N_("Delete a default template combination for an operating system")
      param :operatingsystem_id, :number, :desc => N_("ID of operating system")
      param :id, String, :required => true

      def destroy
        process_response @os_default_template.destroy
      end

      private

      def allowed_nested_id
        %w(operatingsystem_id provisioning_template_id)
      end
    end
  end
end
