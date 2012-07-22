module StatisticsHelper
  def charts
    options = {:class => "statistics_pie small", :expandable => true, :'border' => 0, :show_title => false}
    [
      pie_chart("os_dist" ,"OS Distribution", @os_count, options.merge(:search => "facts.operatingsystem=~VAL1~ and facts.operatingsystemrelease=~VAL2~")),
      pie_chart("arch_dist" ,"Architecture Distribution", @arch_count, options.merge( :search => "facts.architecture=~VAL1~")),
      pie_chart("env_dist" ,"Environments Distribution", @env_count, options.merge( :search => "environment=~VAL1~" )),
      pie_chart("cpu_num" ,"Number of CPUs", @cpu_count,options.merge( :search => "facts.processorcount=~VAL1~")),
      pie_chart("hardware" ,"Hardware", @model_count, options.merge( :search => "facts.manufacturer~~VAL1~")),
      pie_chart("class_dist" ,"Class Distribution", @klass_count, options.merge( :search => "class=~VAL1~")),
      pie_chart("mem_usage" ,"Average memory usage", [["free memory (GB)",@mem_free],["used memory (GB)",@mem_size-@mem_free]], options),
      pie_chart("swap_usage" ,"Average swap usage", [["free swap (GB)",@swap_free],["used swap (GB)",@swap_size-@swap_free]], options),
      pie_chart("mem_totals" ,"Total memory usage", [["free memory (GB)", @mem_totfree],["used memory (GB)",@mem_totsize-@mem_totfree]],options),
    ]
  end
end
