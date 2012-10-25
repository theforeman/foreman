module Api
  module V1
    class AuthSourceLdapsController < V1::BaseController
      
      before_filter :find_resource, :only => :show

      api :GET, "/auth_source_ldaps/", "List all authsource ldaps"
      def index
        @auth_source_ldaps = AuthSourceLdap.paginate(:page => params[:page])
      end

      api :GET, "/auth_source_ldaps/:id/", "Show an authsource ldap."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
