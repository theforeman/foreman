module Api
  module V2
    class RealmsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/realms/", N_("List of realms")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        @realms = Realm.
          authorized(:view_realms).
          search_for(*search_options).paginate(paginate_options)
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
        end
      end

      api :POST, "/realms/", N_("Create a realm")
      description <<-DOC
        The <b>name</b> field is used for the name of the realm.
      DOC
      param_group :realm, :as => :create

      def create
        @realm = Realm.new(params[:realm])
        process_response @realm.save
      end

      api :PUT, "/realms/:id/", N_("Update a realm")
      param :id, :identifier, :required => true
      param_group :realm

      def update
        process_response @realm.update_attributes(params[:realm])
      end

      api :DELETE, "/realms/:id/", N_("Delete a realm")
      param :id, :identifier, :required => true

      def destroy
        process_response @realm.destroy
      end
    end
  end
end
