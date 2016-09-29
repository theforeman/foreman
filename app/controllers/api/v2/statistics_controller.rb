module Api
  module V2
    class StatisticsController < V2::BaseController
      api :GET, "/statistics/", N_("Get statistics")

      def index
        @os_count    = Host.authorized(:view_hosts).count_distribution :operatingsystem
        @arch_count  = Host.authorized(:view_hosts).count_distribution :architecture
        @env_count   = Host.authorized(:view_hosts).count_distribution :environment
        @klass_count = Host.authorized(:view_hosts).count_habtm "puppetclass"
        @cpu_count   = FactValue.authorized(:view_facts).my_facts.count_each "processorcount"
        @model_count = FactValue.authorized(:view_facts).my_facts.count_each "manufacturer"
        @mem_size    = FactValue.authorized(:view_facts).my_facts.mem_average "memorysize"
        @mem_free    = FactValue.authorized(:view_facts).my_facts.mem_average "memoryfree"
        @swap_size   = FactValue.authorized(:view_facts).my_facts.mem_average "swapsize"
        @swap_free   = FactValue.authorized(:view_facts).my_facts.mem_average "swapfree"
        @mem_totsize = FactValue.authorized(:view_facts).my_facts.mem_sum "memorysize"
        @mem_totfree = FactValue.authorized(:view_facts).my_facts.mem_sum "memoryfree"
        render :json => { :os_count    => @os_count,    :arch_count => @arch_count,   :swap_size => @swap_size,
                          :env_count   => @env_count,   :klass_count => @klass_count, :cpu_count => @cpu_count,
                          :model_count => @model_count, :mem_size => @mem_size,       :mem_free => @mem_free,
                          :swap_free   => @swap_free,   :mem_totsize => @mem_totsize, :mem_totfree => @mem_totfree }
      end
    end
  end
end
