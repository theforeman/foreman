module Api
  module V2
    class StatisticsController < V2::BaseController
      include Api::Version2
      include Api::TaxonomyScope

      before_filter :find_resource, :only => %w{show destroy}

      api :GET, "/statistics/", N_("Get statistics")
      api :GET, "/organizations/:organization_id/statistics", N_("View Statistics per organization")
      param_group :taxonomy_scope, ::Api::V2::BaseController

      def index
        @statistic   = Statistic.all.sort_by {|e| e.name.downcase }.paginate(:page => params[:page])
        @os_count    = Host.authorized(:view_hosts).count_distribution :operatingsystem
        @env_count   = Host.authorized(:view_hosts).count_distribution :environment
        @klass_count = Host.authorized(:view_hosts).count_habtm "puppetclass"
        @mem_size    = FactValue.authorized(:view_facts).my_facts.mem_average "memorysize"
        @mem_free    = FactValue.authorized(:view_facts).my_facts.mem_average "memoryfree"
        @swap_size   = FactValue.authorized(:view_facts).my_facts.mem_average "swapsize"
        @swap_free   = FactValue.authorized(:view_facts).my_facts.mem_average "swapfree"
        @mem_totsize = FactValue.authorized(:view_facts).my_facts.mem_sum "memorysize"
        @mem_totfree = FactValue.authorized(:view_facts).my_facts.mem_sum "memoryfree"

        static_stats = { :os_count    => @os_count,    :swap_size => @swap_size,     :env_count   => @env_count,
                         :klass_count => @klass_count, :mem_size => @mem_size,       :mem_free => @mem_free,
                         :swap_free   => @swap_free,   :mem_totsize => @mem_totsize, :mem_totfree => @mem_totfree }
        dynamic_stats = {}
        @statistic.each do |st|
          dynamic_stats[st.name] = FactValue.authorized(:view_facts).my_facts.count_each(st.value)
        end

        stats = static_stats.merge!(dynamic_stats)
        render :json => stats
      end

      api :POST, "/statistics/", N_("Create an Statistic")
      param :name, String, :desc => N_("Statistic name"), :required => true
      param :value, String, :desc => N_("Statistic fact"), :required => true
      param_group :taxonomies, ::Api::V2::BaseController

      def create
        @statistic = Statistic.new(params[:statistic])
        process_response @statistic.save
      end

      api :DELETE, '/statistics/:name', N_("Delete a statistic")
      param :name, String, :desc => N_("Statistic name"), :required => true

      def destroy
        process_response @statistic.destroy
      end
    end
  end
end
