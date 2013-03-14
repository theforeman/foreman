module StatisticsHelper
  def charts
    options = {:class => "statistics-pie small", :expandable => true, :'border' => 0, :show_title => true}
    [
      flot_pie_chart("os_dist" ,"OS Distribution", @os_count, options.merge(:search => "facts.operatingsystem=~VAL1~ and facts.operatingsystemrelease=~VAL2~")),
      flot_pie_chart("arch_dist" ,"Architecture Distribution", @arch_count, options.merge( :search => "facts.architecture=~VAL1~")),
      flot_pie_chart("env_dist" ,"Environments Distribution", @env_count, options.merge( :search => "environment=~VAL1~" )),
      flot_pie_chart("cpu_num" ,"Number of CPUs", @cpu_count,options.merge( :search => "facts.processorcount=~VAL1~")),
      flot_pie_chart("hardware" ,"Hardware", @model_count, options.merge( :search => "facts.manufacturer~~VAL1~")),
      flot_pie_chart("class_dist" ,"Class Distribution", @klass_count, options.merge( :search => "class=~VAL1~")),
      flot_pie_chart("mem_usage" ,"Average memory usage", [{:label=>"free memory (GB)", :data=>@mem_free},{:label=>"used memory (GB)",:date=>@mem_size-@mem_free}], options),
      flot_pie_chart("swap_usage" ,"Average swap usage", [{:label=>"free swap (GB)", :data=>@swap_free},{:label=>"used swap (GB)", :data=>@swap_size-@swap_free}], options),
      flot_pie_chart("mem_totals" ,"Total memory usage", [{:label=>"free (GB)", :data=>@mem_totfree},{:label=>"used (GB)", :data=>@mem_totsize-@mem_totfree}],options),
    ]
  end
end
