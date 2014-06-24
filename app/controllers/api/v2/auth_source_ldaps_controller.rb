module Api
  module V2
    class AuthSourceLdapsController < V2::BaseController

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

      def_param_group :auth_source_ldap do
        param :auth_source_ldap, Hash, :action_aware => true do
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
          param :tls, :bool
        end
      end

      api :POST, "/auth_source_ldaps/", "Create an auth_source_ldap."
      param_group :auth_source_ldap, :as => :create

      def create
        @auth_source_ldap = AuthSourceLdap.new(params[:auth_source_ldap])
        process_response @auth_source_ldap.save
      end

      api :PUT, "/auth_source_ldaps/:id/", "Update an auth_source_ldap."
      param :id, String, :required => true
      param_group :auth_source_ldap

      def update
        process_response @auth_source_ldap.update_attributes(params[:auth_source_ldap])
      end

      api :DELETE, "/auth_source_ldaps/:id/", "Delete an auth_source_ldap."
      param :id, String, :required => true

      def destroy
        process_response @auth_source_ldap.destroy
      end

    end
  end
end
