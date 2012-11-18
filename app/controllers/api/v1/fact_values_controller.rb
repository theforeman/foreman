module Api
  module V1
    class FactValuesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/fact_values/", "List all fact values."
      param :search, String, :desc => "filter results"
      param :order,  String, :desc => "sort results"
      param :page,  String, :desc => "paginate results"
      def index
        values = FactValue.my_facts.no_timestamp_facts.search_for(params[:search],:order => params[:order]).paginate(:page => params[:page])
        @fact_values = FactValue.build_facts_hash(values.all(:include => [:fact_name, :host]))
        render :json => @fact_values
      end

    end
  end
end
