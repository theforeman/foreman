module Api
  module V1
    class FactValuesController < V1::BaseController
      before_filter :find_resource, :only => %w{show update destroy}

      api :GET, "/fact_values/", "List all fact values."
      param :search, String, :desc => "filter results"
      param :order, String, :desc => "sort results"
      param :page, String, :desc => "paginate results"
      param :per_page, String, :desc => "number of entries per request"

      def index
        values = FactValue.my_facts.no_timestamp_facts.
          search_for(*search_options).paginate(paginate_options).
          includes(:fact_name, :host)
        render :json => FactValue.build_facts_hash(values.all)
      end

    end
  end
end
