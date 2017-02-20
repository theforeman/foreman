module Api
  module V2
    class OperatingsystemsController < V2::BaseController
      include Foreman::Controller::Parameters::Operatingsystem
      include ParameterAttributes

      resource_description do
        name 'Operating systems'
      end

      before_action :rename_config_templates, :only => %w{update create}
      before_action :rename_config_template, :only => %w{index}
      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show edit update destroy bootfiles}
      before_action :process_parameter_attributes, :only => %w{update}

      api :GET, "/operatingsystems/", N_("List all operating systems")
      api :GET, "/architectures/:architecture_id/operatingsystems", N_("List all operating systems for nested architecture")
      api :GET, "/media/:medium_id/operatingsystems", N_("List all operating systems for nested medium")
      api :GET, "/ptables/:ptable_id/operatingsystems", N_("List all operating systems for nested partition table")
      api :GET, "/config_templates/:config_template_id/operatingsystems", N_("List all operating systems for nested provisioning template")
      api :GET, "/provisioning_templates/:provisioning_template_id/operatingsystems", N_("List all operating systems for nested provisioning template")
      param :architecture_id, String, :desc => N_("ID of architecture")
      param :medium_id, String, :desc => N_("ID of medium")
      param :ptable_id, String, :desc => N_("ID of partition table")
      param :config_template_id, String, :desc => N_("ID of template")
      param :provisioning_template_id, String, :desc => N_("ID of template")
      param :os_parameters_attributes, Array, :required => false, :desc => N_("Array of parameters")  do
        param :name, String, :desc => N_("Name of the parameter"), :required => true
        param :value, String, :desc => N_("Parameter value"), :required => true
      end
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @operatingsystems = resource_scope_for_index
      end

      api :GET, "/operatingsystems/:id/", N_("Show an operating system")
      param :id, String, :required => true
      param :show_hidden_parameters, :bool, :desc => N_("Display hidden parameter values")

      def show
      end

      def_param_group :operatingsystem do
        param :operatingsystem, Hash, :required => true, :action_aware => true do
          param :name, /\A(\S+)\Z/, :required => true
          param :major, String, :required => true
          param :minor, String
          param :description, String
          param :family, String
          param :release_name, String
          param :os_parameters_attributes, Array, :desc => N_("Array of parameters") do
            param :name, String, :desc => N_("Name of the parameter"), :required => true
            param :value, String, :desc => N_("Parameter value"), :required => true
          end
          param :password_hash, String, :desc => N_('Root password hash function to use, one of MD5, SHA256, SHA512, Base64')
          param :architecture_ids, Array, :desc => N_("IDs of associated architectures")
          param :config_template_ids, Array, :desc => N_("IDs of associated provisioning templates") # FIXME: deprecated
          param :provisioning_template_ids, Array, :desc => N_("IDs of associated provisioning templates")
          param :medium_ids, Array, :desc => N_("IDs of associated media")
          param :ptable_ids, Array, :desc => N_("IDs of associated partition tables")
        end
      end

      api :POST, "/operatingsystems/", N_("Create an operating system")
      param_group :operatingsystem, :as => :create

      def create
        @operatingsystem = Operatingsystem.new(operatingsystem_params)
        process_response @operatingsystem.save
      end

      api :PUT, "/operatingsystems/:id/", N_("Update an operating system")
      param :id, String, :required => true
      param_group :operatingsystem

      def update
        process_response @operatingsystem.update_attributes(operatingsystem_params)
      end

      api :DELETE, "/operatingsystems/:id/", N_("Delete an operating system")
      param :id, String, :required => true

      def destroy
        process_response @operatingsystem.destroy
      end

      api :GET, "/operatingsystems/:id/bootfiles/", N_("List boot files for an operating system")
      param :id, String, :required => true
      param :medium, String
      param :architecture, String

      def bootfiles
        medium = Medium.authorized(:view_media).find(params[:medium])
        arch   = Architecture.authorized(:view_architectures).find(params[:architecture])
        render :json => @operatingsystem.pxe_files(medium, arch)
      rescue => e
        render_message(e.to_s, :status => :unprocessable_entity)
      end

      private

      def rename_config_templates
        if params[:operatingsystem] && params[:operatingsystem][:config_template_ids].present?
          params[:operatingsystem][:provisioning_template_ids] = params[:operatingsystem].delete(:config_template_ids)
          ::ActiveSupport::Deprecation.warn('Config templates were renamed to provisioning templates')
        end
      end

      def rename_config_template
        if params[:config_template_id].present?
          params[:provisioning_template_id] = params.delete(:config_template_id)
          ::ActiveSupport::Deprecation.warn('Config templates were renamed to provisioning templates')
        end
      end

      def allowed_nested_id
        %w(architecture_id medium_id ptable_id provisioning_template_id)
      end
    end
  end
end
