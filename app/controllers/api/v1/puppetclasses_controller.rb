module Api
  module V1
    class PuppetclassesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}
      before_filter :setup_search_options, :only => :index

      api :GET, "/puppetclasses/", "List all puppetclasses."
      api :GET, "/hosts/:host_id/puppetclasses/", "List all puppetclasses of a given host."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        values = Puppetclass.
          authorized(:view_puppetclasses).
          search_for(*search_options).paginate(paginate_options).
          select([:name, :id]).
          includes(:lookup_keys).to_a
        render :json => Puppetclass.classes2hash(values)
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
        @puppetclass = Puppetclass.new(foreman_params)
        process_response @puppetclass.save
      end

      api :PUT, "/puppetclasses/:id/", "Update a puppetclass."
      param :id, String, :required => true
      param :puppetclass, Hash, :required => true do
        param :name, String
      end

      def update
        process_response @puppetclass.update_attributes(foreman_params)
      end

      api :DELETE, "/puppetclasses/:id/", "Delete a puppetclass."
      param :id, String, :required => true

      def destroy
        process_response @puppetclass.destroy
      end
    end
  end
end
