class StatisticsController < ApplicationController
  before_filter :find_resource, :only => %w{show destroy}

  def index
    @statistic   = Statistic.all.sort_by {|e| e.name.downcase }.paginate(:page => params[:page])
    @os_count    = Host.authorized(:view_hosts, Host).count_distribution :operatingsystem
    @env_count   = Host.authorized(:view_hosts, Host).count_distribution :environment
    @klass_count = Puppetclass.authorized(:view_puppetclasses).where('total_hosts>0').map{|pc| {:label=>pc.to_label, :data =>pc.total_hosts}}
    @mem_size    = FactValue.authorized(:view_facts).my_facts.mem_average "memorysize"
    @mem_free    = FactValue.authorized(:view_facts).my_facts.mem_average "memoryfree"
    @swap_size   = FactValue.authorized(:view_facts).my_facts.mem_average "swapsize"
    @swap_free   = FactValue.authorized(:view_facts).my_facts.mem_average "swapfree"
    respond_to do |format|
      format.html
      format.json do
        render :json => { :statistics => { :os_count    => @os_count,    :swap_size => @swap_size,     :env_count   => @env_count,
                                           :klass_count => @klass_count, :mem_size => @mem_size,       :mem_free => @mem_free,
                                           :swap_free   => @swap_free,   :mem_totsize => @mem_totsize, :mem_totfree => @mem_totfree } }
      end
    end
  end

  def new
    @statistic = Statistic.new
  end

  def create
    @statistic = Statistic.new(params[:statistic])
    if @statistic.save
      process_success
    else
      process_error
    end
  end

  def destroy
    if @statistic.destroy
      process_success
    else
      process_error
    end
  end
end
