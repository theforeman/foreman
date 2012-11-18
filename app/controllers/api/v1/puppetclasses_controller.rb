module Api
  module V1
    class PuppetclassesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/puppetclasses/", "List all puppetclasses."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      param :page,  String, :desc => "paginate results"
      def index
        values = Puppetclass.search_for(params[:search], :order => params[:order]).paginate(:page => params[:page])
        @puppetclasses = Puppetclass.classes2hash(values.all(:select => "name, id"))
        render :json => @puppetclasses

      end

      api :GET, "/puppetclasses/:id/", "Show a puppetclass."
      param :id, :identifier, :required => true
      def show
      end

      api :POST, "/puppetclasses/", "Create a puppetclass."
      param :puppetclass, Hash, :required => true do
        param :name, String, :required => true
      end
      def create
        @puppetclass = Puppetclass.new(params[:puppetclass])
        process_response @puppetclass.save
      end

      api :PUT, "/puppetclasses/:id/", "Update a puppetclass."
      param :id, String, :required => true
      param :puppetclass, Hash, :required => true do
        param :name, String, :required => true
      end
      def update
        process_response @puppetclass.update_attributes(params[:puppetclass])
      end

      api :DELETE, "/puppetclasses/:id/", "Delete a puppetclass."
      param :id, String, :required => true
      def destroy
        process_response @puppetclass.destroy
      end

    end
  end
end
