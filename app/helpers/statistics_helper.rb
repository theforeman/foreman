module StatisticsHelper
  def charts
    options = {:class => "statistics-pie small", :expandable => true, :'border' => 0, :show_title => true}
    [
      flot_pie_chart("os_dist" ,_("OS Distribution"), @os_count, options.merge(:search => "os_description=~VAL1~")),
      flot_pie_chart("arch_dist" ,_("Architecture Distribution"), @arch_count, options.merge( :search => "facts.architecture=~VAL1~")),
      flot_pie_chart("env_dist" ,_("Environments Distribution"), @env_count, options.merge( :search => "environment=~VAL1~" )),
      flot_pie_chart("cpu_num" ,_("Number of CPUs"), @cpu_count,options.merge( :search => "facts.processorcount=~VAL1~")),
      flot_pie_chart("hardware" ,_("Hardware"), @model_count, options.merge( :search => "facts.manufacturer~~VAL1~")),
      flot_pie_chart("class_dist" ,_("Class Distribution"), @klass_count, options.merge( :search => "class=~VAL1~")),
      flot_pie_chart("mem_usage" ,_("Average memory usage"), [{:label=>_("free memory"), :data=>@mem_free},{:label=>_("used memory"),:data=>@mem_size-@mem_free}], options),
      flot_pie_chart("swap_usage" ,_("Average swap usage"), [{:label=>_("free swap"), :data=>@swap_free},{:label=>_("used swap"), :data=>@swap_size-@swap_free}], options)
    ]
  end
end
