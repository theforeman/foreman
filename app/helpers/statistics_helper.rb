module StatisticsHelper
  def charts
    options = {:class => "statistics_pie small", :expandable => true, :'border' => 0, :show_title => false}
    [
      pie_chart("os_dist" ,_("OS Distribution"), @os_count, options.merge(:search => "facts.operatingsystem=~VAL1~ and facts.operatingsystemrelease=~VAL2~")),
      pie_chart("arch_dist" ,_("Architecture Distribution"), @arch_count, options.merge( :search => "facts.architecture=~VAL1~")),
      pie_chart("env_dist" ,_("Environments Distribution"), @env_count, options.merge( :search => "environment=~VAL1~" )),
      pie_chart("cpu_num" ,_("Number of CPUs"), @cpu_count,options.merge( :search => "facts.processorcount=~VAL1~")),
      pie_chart("hardware" ,_("Hardware"), @model_count, options.merge( :search => "facts.manufacturer~~VAL1~")),
      pie_chart("class_dist" ,_("Class Distribution"), @klass_count, options.merge( :search => "class=~VAL1~")),
      pie_chart("mem_usage" ,_("Average memory usage"), [[_("free memory (GB)"),@mem_free],[_("used memory (GB)"),@mem_size-@mem_free]], options),
      pie_chart("swap_usage" ,_("Average swap usage"), [[_("free swap (GB)"),@swap_free],[_("used swap (GB)"),@swap_size-@swap_free]], options),
      pie_chart("mem_totals" ,_("Total memory usage"), [[_("free memory (GB)"), @mem_totfree],[_("used memory (GB)"),@mem_totsize-@mem_totfree]],options),
    ]
  end
end
