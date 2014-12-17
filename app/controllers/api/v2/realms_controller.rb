module Api
  module V2
    class RealmsController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/realms/", N_("List of realms")
      param_group :taxonomy_scope, ::Api::V2::BaseController
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @realms = resource_scope_for_index
      end

      api :GET, "/realms/:id/", N_("Show a realm")
      param :id, :identifier, :required => true, :desc => N_("Numerical ID or realm name")

      def show
      end

      def_param_group :realm do
        param :realm, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_("The realm name, e.g. EXAMPLE.COM")
          param :realm_proxy_id, :number, :required => true, :allow_nil => true, :desc => N_("Proxy to use for this realm")
          param :realm_type, String, :required => true, :desc => N_("Realm type, e.g. FreeIPA or Active Directory")
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, "/realms/", N_("Create a realm")
      description <<-DOC
        The <b>name</b> field is used for the name of the realm.
      DOC
      param_group :realm, :as => :create

      def create
        @realm = Realm.new(foreman_params)
        process_response @realm.save
      end

      api :PUT, "/realms/:id/", N_("Update a realm")
      param :id, :identifier, :required => true
      param_group :realm

      def update
        process_response @realm.update_attributes(foreman_params)
      end

      api :DELETE, "/realms/:id/", N_("Delete a realm")
      param :id, :identifier, :required => true

      def destroy
        process_response @realm.destroy
      end
    end
  end
end
