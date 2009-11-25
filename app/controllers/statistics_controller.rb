class StatisticsController < ApplicationController

  def index
    begin
      @os_count = Host.count_distribution :operatingsystem
      @arch_count = Host.count_distribution :architecture
      @env_count = Host.count_distribution :environment
      @klass_count = Host.count_habtm "puppetclass"
      @cpu_count = FactValue.count_each "processorcount"
      @model_count = FactValue.count_each "manufacturer"
      @mem_size = FactValue.mem_average "memorysize"
      @mem_free = FactValue.mem_average "memoryfree"
      @swap_size = FactValue.mem_average "swapsize"
      @swap_free = FactValue.mem_average "swapfree"
    rescue
      render :text => "No Inventory data has been found - add some hosts and facts and try again", :layout => true
    end
  end

end
