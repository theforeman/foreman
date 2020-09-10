module Api
  module V2
    class PtablesController < V2::BaseController
      include Foreman::Controller::Parameters::Ptable
      include Foreman::Controller::TemplateImport

      wrap_parameters :ptable, :include => ptable_params_filter.accessible_attributes(parameter_filter_context)

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone export}

      api :GET, "/ptables/", N_("List all partition tables")
      api :GET, "/operatingsystems/:operatingsystem_id/ptables", N_("List all partition tables for an operating system")
      api :GET, "/locations/:location_id/ptables/", N_("List all partition tables per location")
      api :GET, "/organizations/:organization_id/ptables/", N_("List all partition tables per organization")
      param :operatingsystem_id, String, :desc => N_("ID of operating system")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Ptable)

      def index
        @ptables = resource_scope_for_index
      end

      api :GET, "/ptables/:id/", N_("Show a partition table")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :ptable do
        param :ptable, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :description, String
          param :layout, String, :required => true
          param :snippet, :bool, :allow_nil => true
          param :audit_comment, String, :allow_nil => true
          param :locked, :bool, :desc => N_("Whether or not the template is locked for editing")
          param :os_family, String, :required => false
          param :operatingsystem_ids, Array, :desc => N_("Array of operating system IDs to associate with the partition table")
          param :host_ids, Array, :desc => N_("Array of host IDs to associate with the partition table")
          param :hostgroup_ids, Array, :desc => N_("Array of host group IDs to associate with the partition table")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/ptables/", N_("Create a partition table")
      param_group :ptable, :as => :create

      def create
        @ptable = Ptable.new(ptable_params)
        process_response @ptable.save
      end

      api :POST, "/ptables/import", N_("Import a provisioning template")
      param :ptable, Hash, :required => true, :action_aware => true do
        param :name, String, :required => true, :desc => N_("template name")
        param :template, String, :required => true, :desc => N_("template contents including metadata")
        param_group :taxonomies, ::Api::V2::BaseController
      end
      param_group :template_import_options, ::Api::V2::BaseController

      def import
        @ptable = Ptable.import!(*import_attrs_for(:ptable))
        process_response @ptable
      end

      api :GET, "/ptables/revision"
      param :version, String, :desc => N_("template version")

      def revision
        audit = Audit.authorized(:view_audit_logs).find(params[:version])
        render :json => audit.revision.template
      end

      api :PUT, "/ptables/:id/", N_("Update a partition table")
      param :id, String, :required => true
      param_group :ptable

      def update
        process_response @ptable.update(ptable_params)
      end

      api :DELETE, "/ptables/:id/", N_("Delete a partition table")
      param :id, String, :required => true

      def destroy
        process_response @ptable.destroy
      end

      def_param_group :ptable_clone do
        param :ptable, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("template name")
        end
      end

      api :POST, "/ptables/:id/clone", N_("Clone a template")
      param :id, :identifier, :required => true
      param_group :ptable_clone, :as => :create

      def clone
        @ptable = @ptable.clone
        load_vars_from_ptable
        @ptable.name = params[:ptable][:name]
        process_response @ptable.save
      end

      api :GET, '/ptables/:id/export', N_('Export a partition template to ERB')
      param :id, :identifier, :required => true
      def export
        send_data @ptable.to_erb, :type => 'text/plain', :disposition => 'attachment', :filename => @ptable.filename
      end

      private

      def load_vars_from_ptable
        return unless @ptable

        @locations        = @ptable.locations
        @organizations    = @ptable.organizations
        @operatingsystems = @ptable.operatingsystems
      end

      def allowed_nested_id
        %w(operatingsystem_id)
      end

      def action_permission
        case params[:action]
          when 'clone', 'import'
            'create'
          when 'export'
            'view'
          else
            super
        end
      end
    end
  end
end
