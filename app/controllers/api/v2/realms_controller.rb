module Api
  module V2
    class RealmsController < V2::BaseController

      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/realms/", "List of realms"
      param :search, String, :desc => "Filter results"
      param :order, String, :desc => "Sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @realms = Realm.
          authorized(:view_realms).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/realms/:id/", "Show a realm."
      param :id, :identifier, :required => true, :desc => "May be numerical id or realm name"

      def show
      end

      def_param_group :realm do
        param :name, String, :required => true, :action_aware => true, :desc => "The realm name, e.g. EXAMPLE.COM"
        param :realm_proxy_id, :number, :required => false, :allow_nil => true, :desc => "Proxy to use for this realm"
        param :realm_type, String, :required => true, :action_aware => true, :desc => "Realm type, e.g. FreeIPA or Active Directory"
      end

      api :POST, "/realms/", "Create a realm."
      # TRANSLATORS: API documentation - do not translate
      description <<-DOC
        The <b>name</b> field is used for the name of the realm.
      DOC
      param_group :realm, :as => :create

      def create
        @realm = Realm.new(params[:realm])
        process_response @realm.save
      end

      api :PUT, "/realms/:id/", "Update a realm."
      param :id, :identifier, :required => true
      param_group :realm

      def update
        process_response @realm.update_attributes(params[:realm])
      end

      api :DELETE, "/realms/:id/", "Delete a realm."
      param :id, :identifier, :required => true

      def destroy
        process_response @realm.destroy
      end
    end
  end
end
