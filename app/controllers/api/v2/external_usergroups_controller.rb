module Api
  module V2
    class ExternalUsergroupsController < V2::BaseController
      include Api::Version2
      include Foreman::Controller::Parameters::ExternalUsergroup

      before_action :find_resource, :only => [:show, :update, :destroy, :refresh]
      before_action :find_required_nested_object, :only => [:index, :show, :create]
      after_action :refresh_external_usergroup, :only => [:create, :update, :destroy]

      api :GET, '/usergroups/:usergroup_id/external_usergroups', N_('List all external user groups for user group')
      api :GET, '/auth_source_ldaps/:auth_source_ldap_id/external_usergroups', N_('List all external user groups for LDAP authentication source')
      param :usergroup_id, String, :required => true, :desc => N_('ID or name of user group')

      def index
        @external_usergroups = resource_scope.paginate(paginate_options)
      end

      api :GET, '/usergroups/:usergroup_id/external_usergroups/:id', N_('Show an external user group for user group')
      api :GET, '/auth_source_ldaps/:auth_source_ldap_id/external_usergroups/:id', N_('Show an external user group for LDAP authentication source')
      param :usergroup_id, String, :required => true, :desc => N_('ID or name of user group')
      param :id, String, :required => true, :desc => N_('ID or name of external user group')

      def show
      end

      def_param_group :external_usergroup do
        param :external_usergroup, Hash, :required => true, :action_aware => true, :desc => N_('External user group information') do
          param :name, String, :required => true, :desc => N_('External user group name')
          param :auth_source_id, :number, :required => true, :desc => N_('ID of linked authentication source')
        end
      end

      api :POST, '/usergroups/:usergroup_id/external_usergroups', N_('Create an external user group linked to a user group')
      param :usergroup_id, String, :required => true, :desc => N_('ID or name of user group')
      param_group :external_usergroup, :as => :create

      def create
        @external_usergroup = @nested_obj.external_usergroups.new(external_usergroup_params)
        process_response @external_usergroup.save
      end

      api :PUT, '/usergroups/:usergroup_id/external_usergroups/:id', N_('Update external user group')
      param :usergroup_id, String, :required => true, :desc => N_('ID or name of user group')
      param :id, String, :required => true, :desc => N_('ID or name of external user group')
      param_group :external_usergroup

      def update
        process_response @external_usergroup.update(external_usergroup_params)
      end

      api :PUT, '/usergroups/:usergroup_id/external_usergroups/:id/refresh', N_('Refresh external user group')
      param :usergroup_id, String, :required => true, :desc => N_('ID or name of user group')
      param :id, String, :required => true, :desc => N_('ID or name of external user group')

      def refresh
        process_response @external_usergroup.refresh
      end

      api :DELETE, '/usergroups/:usergroup_id/external_usergroups/:id', N_('Delete an external user group')
      param :usergroup_id, String, :required => true, :desc => N_('ID or name of user group')
      param :id, String, :required => true, :desc => N_('ID or name external user group')

      def destroy
        process_response @external_usergroup.destroy
      end

      private

      def action_permission
        case params[:action]
        when 'refresh'
          :edit
        else
          super
        end
      end

      def allowed_nested_id
        %w(usergroup_id auth_source_ldap_id)
      end

      def refresh_external_usergroup
        @external_usergroup.refresh
      end
    end
  end
end
