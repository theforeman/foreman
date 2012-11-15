module Api
  module V1
    class PtablesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/ptables/", "List all ptables."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        @ptables = Ptable.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
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
        @ptable = Ptable.new(params[:ptable])
        process_response @ptable.save
      end

      api :PUT, "/ptables/:id/", "Update a ptable."
      param :id, String, :required => true
      param :ptable, Hash, :required => true do
        param :name, String, :required => true
        param :layout, String, :required => true
        param :os_family, String, :required => false
      end
      def update
        process_response @ptable.update_attributes(params[:ptable])
      end

      api :DELETE, "/ptables/:id/", "Delete a ptable."
      param :id, String, :required => true
      def destroy
        process_response @ptable.destroy
      end

    end
  end
end
