class StatisticsController < ApplicationController

  def index
    my_hosts = User.current.admin? ? Host : Host.my_hosts
    my_facts = User.current.admin? ? FactValue : FactValue.my_facts
    @os_count    = my_hosts.count_distribution :operatingsystem
    @arch_count  = my_hosts.count_distribution :architecture
    @env_count   = my_hosts.count_distribution :environment
    @klass_count = my_hosts.count_habtm "puppetclass"
    @cpu_count   = my_facts.count_each "processorcount"
    @model_count = my_facts.count_each "manufacturer"
    @mem_size    = my_facts.mem_average "memorysize"
    @mem_free    = my_facts.mem_average "memoryfree"
    @swap_size   = my_facts.mem_average "swapsize"
    @swap_free   = my_facts.mem_average "swapfree"
    @mem_totsize = my_facts.mem_sum "memorysize"
    @mem_totfree = my_facts.mem_sum "memoryfree"
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
