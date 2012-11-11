module Api
  module V1
    class AuthSourceLdapsController < V1::BaseController
      
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/auth_source_ldaps/", "List all authsource ldaps"
      def index
        @auth_source_ldaps = AuthSourceLdap.paginate(:page => params[:page])
      end

      api :GET, "/auth_source_ldaps/:id/", "Show an authsource ldap."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/auth_source_ldaps/", "Create an auth_source_ldap."
      param :auth_source_ldap, Hash, :required => true do
        param :name, String, :required => true
        param :host, String
        param :port, String
        param :account, String
        param :base_dn, String
        param :account_password, String
        param :attr_login, String
        param :attr_firstname, String
        param :attr_lastname, String
        param :attr_mail, String
        param :onthefly_register, String
        param :tls, String, :desc => "Boolean value True/False"
      end
      def create
        @auth_source_ldap = AuthSourceLdap.new(params[:auth_source_ldap])
        process_response @auth_source_ldap.save
      end

      api :PUT, "/auth_source_ldaps/:id/", "Update an auth_source_ldap."
      param :id, String, :required => true
      param :auth_source_ldap, Hash, :required => true do
        param :name, String, :required => true
        param :host, String
        param :port, String
        param :account, String
        param :base_dn, String
        param :account_password, String
        param :attr_login, String
        param :attr_firstname, String
        param :attr_lastname, String
        param :attr_mail, String
        param :onthefly_register, String
        param :tls, Boolean
      end
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
