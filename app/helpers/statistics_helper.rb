module StatisticsHelper

  def charts
    [
      pie_chart("os_dist" ,"OS Distribution", @os_count, :class => "statistics_pie small"),
      pie_chart("arch_dist" ,"Architecture Distribution", @arch_count, :class => "statistics_pie small"),
      pie_chart("env_dist" ,"Environments Distribution", @env_count, :class => "statistics_pie small"),
      pie_chart("cpu_num" ,"Number of CPUs", @cpu_count, :class => "statistics_pie small"),
      pie_chart("hardware" ,"Hardware", @model_count, :class => "statistics_pie small"),
      pie_chart("class_dist" ,"Class Distribution", @klass_count, :class => "statistics_pie small"),
      pie_chart("mem_usage" ,"Average memory usage", [["free memory (GB)",@mem_free],["used memory (GB)",@mem_size-@mem_free]], :class => "statistics_pie small"),
      pie_chart("swap_usage" ,"Average swap usage", [["free swap (GB)",@swap_free],["used swap (GB)",@swap_size-@swap_free]], :class => "statistics_pie small"),
      pie_chart("mem_totals" ,"Total memory usage", [["free memory (GB)", @mem_totfree],["used memory (GB)",@mem_totsize-@mem_totfree]], :class => "statistics_pie small"),
    ]
  end
end
