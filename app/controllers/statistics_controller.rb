class StatisticsController < ApplicationController

  def index
    @os_count    = Host.authorized(:view_hosts, Host).count_distribution :operatingsystem
    @arch_count  = Host.authorized(:view_hosts, Host).count_distribution :architecture
    @env_count   = Host.authorized(:view_hosts, Host).count_distribution :environment
    @klass_count = Host.authorized(:view_hosts, Host).count_habtm "puppetclass"
    @cpu_count   = FactValue.authorized(:view_facts).my_facts.count_each "processorcount", :unit => Nn_('%s core', '%s cores')
    @model_count = FactValue.authorized(:view_facts).my_facts.count_each "manufacturer"
    @mem_size    = FactValue.authorized(:view_facts).my_facts.mem_average "memorysize"
    @mem_free    = FactValue.authorized(:view_facts).my_facts.mem_average "memoryfree"
    @swap_size   = FactValue.authorized(:view_facts).my_facts.mem_average "swapsize"
    @swap_free   = FactValue.authorized(:view_facts).my_facts.mem_average "swapfree"
    respond_to do |format|
      format.html
      format.json do
        render :json => { :statistics => { :os_count    => @os_count, :arch_count => @arch_count,
                                           :env_count   => @env_count, :klass_count => @klass_count, :cpu_count => @cpu_count,
                                           :model_count => @model_count, :mem_size => @mem_size, :mem_free => @mem_free, :swap_size => @swap_size,
                                           :swap_free   => @swap_free, :mem_totsize => @mem_totsize, :mem_totfree => @mem_totfree } }
      end
    end
  end

end
