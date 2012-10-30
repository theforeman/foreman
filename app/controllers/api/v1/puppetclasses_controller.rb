module Api
  module V1
    class PuppetclassesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/puppetclasses/", "List all puppetclasses."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        values = Puppetclass.search_for(params[:search], :order => params[:order])
        @hash_puppetclasses = Puppetclass.classes2hash(values.all(:select => "name, id"))
        @puppetclasses = OpenStruct.new(@hash_puppetclasses)
      end

      api :GET, "/puppetclasses/:id/", "Show a puppetclass."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
