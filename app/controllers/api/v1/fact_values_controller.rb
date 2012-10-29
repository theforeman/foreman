module Api
  module V1
    class FactValuesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/fact_values/", "List all fact values."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      def index
        values = FactValue.my_facts.no_timestamp_facts.search_for(params[:search],:order => params[:order])
        @fact_values = FactValue.build_facts_hash(values.all(:include => [:fact_name, :host]))
      end

      api :GET, "/fact_values/:id/", "Show an audit."
      param :id, :identifier, :required => true
      def show
      end

    end
  end
end
