module Api
  module V2
    class AuthSourceLdapsController < V2::BaseController
      include Foreman::Controller::Parameters::AuthSourceLdap

      resource_description do
        param :location_id, Integer, :required => false, :desc => N_("Set the current location context for the request")
        param :organization_id, Integer, :required => false, :desc => N_("Set the current organization context for the request")
      end

      wrap_parameters AuthSourceLdap,
        :include => auth_source_ldap_params_filter.
                      accessible_attributes(parameter_filter_context)

      before_action :find_resource, :only => %w{show update destroy test}

      api :GET, "/auth_source_ldaps/", N_("List all LDAP authentication sources")
      api :GET, '/locations/:location_id/auth_source_ldaps/',
        N_('List LDAP authentication sources per location')
      api :GET, '/organizations/:organization_id/auth_source_ldaps/',
        N_('List LDAP authentication sources per organization')
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(AuthSourceLdap)

      def index
        @auth_source_ldaps = resource_scope_for_index
      end

      api :GET, "/auth_source_ldaps/:id/", N_("Show an LDAP authentication source")
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :auth_source_ldap do
        param :auth_source_ldap, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true
          param :host, String, :required => true, :desc => N_("The hostname of the LDAP server")
          param :port, :number, :desc => N_("defaults to 389")
          param :account, String
          param :base_dn, String
          param :account_password, String, :desc => N_("required if onthefly_register is true")
          param :attr_login, String, :desc => N_("required if onthefly_register is true"), :default_value => 'uid'
          param :attr_firstname, String, :desc => N_("required if onthefly_register is true"), :default_value => 'givenName'
          param :attr_lastname, String, :desc => N_("required if onthefly_register is true"), :default_value => 'sn'
          param :attr_mail, String, :desc => N_("required if onthefly_register is true"), :default_value => 'mail'
          param :attr_photo, String, :default_value => 'jpegPhoto'
          param :onthefly_register, :bool
          param :usergroup_sync, :bool, :desc => N_("sync external user groups on login")
          param :tls, :bool
          param :groups_base, String, :desc => N_("groups base DN")
          param :use_netgroups, :bool, :desc => N_("use NIS netgroups instead of posix groups, applicable only when server_type is posix or free_ipa")
          param :server_type, AuthSourceLdap::SERVER_TYPES.keys, :desc => N_("type of the LDAP server")
          param :ldap_filter, String, :desc => N_("LDAP filter")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/auth_source_ldaps/", N_("Create an LDAP authentication source")
      param_group :auth_source_ldap, :as => :create

      def create
        @auth_source_ldap = AuthSourceLdap.new(auth_source_ldap_params)
        process_response @auth_source_ldap.save
      end

      api :PUT, "/auth_source_ldaps/:id/", N_("Update an LDAP authentication source")
      param :id, String, :required => true
      param_group :auth_source_ldap

      def update
        process_response @auth_source_ldap.update(auth_source_ldap_params)
      end

      api :PUT, "/auth_source_ldaps/:id/test/", N_("Test LDAP connection")
      param :id, String, :required => true

      def test
        begin
          test = @auth_source_ldap.test_connection
        rescue Foreman::Exception => exception
          render :test, :locals => {:success => false, :message => exception.message}
          return
        end
        render :test, :locals => {:success => true, :message => test[:message]}
      end

      api :DELETE, "/auth_source_ldaps/:id/", N_("Delete an LDAP authentication source")
      param :id, String, :required => true

      def destroy
        process_response @auth_source_ldap.destroy
      end

      private

      def action_permission
        case params[:action]
          when 'test'
            'edit'
          else
            super
        end
      end

      def controller_permission
        'authenticators'
      end
    end
  end
end
