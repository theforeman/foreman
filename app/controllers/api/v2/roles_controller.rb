module Api
  module V2
    class RolesController < V2::BaseController
      include Foreman::Controller::Parameters::Role

      resource_description do
        param :location_id, Integer, :required => false, :desc => N_("Set the current location context for the request")
        param :organization_id, Integer, :required => false, :desc => N_("Set the current organization context for the request")
      end

      before_action :find_optional_nested_object
      before_action :find_resource, :only => %w{show update destroy clone}

      api :GET, "/roles/", N_("List all roles")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(Role)

      def index
        params[:order] ||= 'name'
        @roles = resource_scope_for_index
      end

      api :GET, "/roles/:id/", N_("Show a role")
      param :id, :identifier, :required => true
      param :description, String, :required => false

      def show
      end

      def_param_group :role do
        param :role, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :description, String, :desc => N_('Role description')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/roles/", N_("Create a role")
      param_group :role, :as => :create

      def create
        @role = Role.new(role_params)
        process_response @role.save
      end

      api :PUT, "/roles/:id/", N_("Update a role")
      param :id, String, :required => true
      param_group :role

      def update
        process_response @role.update(role_params)
      end

      api :DELETE, "/roles/:id/", N_("Delete a role")
      param :id, String, :required => true

      def destroy
        process_response @role.destroy
      end

      api :POST, "/roles/:id/clone", N_("Clone a role")
      param :id, String, :required => true
      param_group :role
      def clone
        @role = @role.clone(role_params)
        process_response @role.save
      end

      private

      def allowed_nested_id
        %w(user_id)
      end

      def action_permission
        case params[:action]
        when 'clone'
          :create
        else
          super
        end
      end
    end
  end
end
