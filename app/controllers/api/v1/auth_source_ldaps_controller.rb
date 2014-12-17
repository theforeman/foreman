module Api
  module V1
    class AuthSourceLdapsController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/auth_source_ldaps/", "List all authsource ldaps"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @auth_source_ldaps = AuthSourceLdap.paginate(paginate_options)
      end

      api :GET, "/auth_source_ldaps/:id/", "Show an authsource ldap."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/auth_source_ldaps/", "Create an auth_source_ldap."
      param :auth_source_ldap, Hash, :required => true do
        param :name, String, :required => true
        param :host, String, :required => true
        param :port, :number, :desc => "defaults to 389"
        param :account, String
        param :base_dn, String
        param :account_password, String, :desc => "required if onthefly_register is true"
        param :attr_login, String, :desc => "required if onthefly_register is true"
        param :attr_firstname, String, :desc => "required if onthefly_register is true"
        param :attr_lastname, String, :desc => "required if onthefly_register is true"
        param :attr_mail, String, :desc => "required if onthefly_register is true"
        param :attr_photo, String
        param :onthefly_register, :bool
        param :usergroup_sync, :bool, :desc => N_("sync external user groups on login")
        param :tls, :bool
      end

      def create
        @auth_source_ldap = AuthSourceLdap.new(foreman_params)
        process_response @auth_source_ldap.save
      end

      api :PUT, "/auth_source_ldaps/:id/", "Update an auth_source_ldap."
      param :id, String, :required => true
      param :auth_source_ldap, Hash, :required => true do
        param :name, String
        param :host, String
        param :port, :number, :desc => "defaults to 389"
        param :account, String
        param :base_dn, String
        param :account_password, String, :desc => "required if onthefly_register is true"
        param :attr_login, String, :desc => "required if onthefly_register is true"
        param :attr_firstname, String, :desc => "required if onthefly_register is true"
        param :attr_lastname, String, :desc => "required if onthefly_register is true"
        param :attr_mail, String, :desc => "required if onthefly_register is true"
        param :attr_photo, String
        param :onthefly_register, :bool
        param :usergroup_sync, :bool, :desc => N_("sync external user groups on login")
        param :tls, :bool
      end

      def update
        process_response @auth_source_ldap.update_attributes(foreman_params)
      end

      api :DELETE, "/auth_source_ldaps/:id/", "Delete an auth_source_ldap."
      param :id, String, :required => true

      def destroy
        process_response @auth_source_ldap.destroy
      end
    end
  end
end
