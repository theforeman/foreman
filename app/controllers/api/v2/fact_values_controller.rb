module Api
  module V2
    class FactValuesController < V2::BaseController
      before_action :setup_search_options, :only => :index

      api :GET, "/fact_values/", N_("List all fact values")
      api :GET, "/hosts/:host_id/facts/", N_("List all fact values of a given host")
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(FactValue)

      def index
        values = FactValue.
          authorized(:view_facts).
          my_facts.
          no_timestamp_facts.
          search_for(*search_options).paginate(paginate_options).
          joins(:fact_name, :host).
          pluck(:value, 'fact_names.name', 'hosts.name')
        @fact_values = build_facts_hash(values)
      end

      def setup_search_options
        params[:search] ||= ""
        params[:search] += " host = " + params[:host_id] if params[:host_id]
      end

      private

      def build_facts_hash(facts)
        facts.each_with_object({}) { |(value, factname, hostname), h| (h[hostname] ||= {})[factname] = value }
      end
    end
  end
end
