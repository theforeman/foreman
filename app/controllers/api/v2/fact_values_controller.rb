module Api
  module V2
    class FactValuesController < V2::BaseController
      before_filter :setup_search_options, :only => :index

      api :GET, "/fact_values/", N_("List all fact values")
      api :GET, "/hosts/:host_id/facts/", N_("List all fact values of a given host")
      param :search, String, :desc => N_("filter results")
      param :order, String, :desc => N_("sort results")
      param :page, String, :desc => N_("paginate results")
      param :per_page, String, :desc => N_("number of entries per request")

      def index
        values = resource_scope.includes(:fact_name, :host).search_for(*search_options).paginate(paginate_options)
        @fact_values = FactValue.build_facts_hash(values.all)
      end

      def resource_scope(controller = controller_name)
        FactValue.authorized(:view_facts).my_facts.no_timestamp_facts
      end

    end
  end
end
