module Api
  module V1
    class PtablesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/ptables/", "List all ptables."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        @ptables = Ptable.
          authorized(:view_ptables).
          search_for(*search_options).paginate(paginate_options)
      end

      api :GET, "/ptables/:id/", "Show a ptable."
      param :id, :identifier, :required => true

      def show
      end

      api :POST, "/ptables/", "Create a ptable."
      param :ptable, Hash, :required => true do
        param :name, String, :required => true
        param :layout, String, :required => true
        param :os_family, String, :required => false
      end

      def create
        @ptable = Ptable.new(foreman_params)
        process_response @ptable.save
      end

      api :PUT, "/ptables/:id/", "Update a ptable."
      param :id, String, :required => true
      param :ptable, Hash, :required => true do
        param :name, String
        param :layout, String
        param :os_family, String
      end

      def update
        process_response @ptable.update_attributes(foreman_params)
      end

      api :DELETE, "/ptables/:id/", "Delete a ptable."
      param :id, String, :required => true

      def destroy
        process_response @ptable.destroy
      end
    end
  end
end
