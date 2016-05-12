module StatisticsHelper
  def charts
    { :os => @os_count, :arch => @arch_count, :env => @env_count,
      :cpu => @cpu_count, :hardware => @model_count,
      :class_dist => @klass_count,
      :mem_usage => [ { :label => _("free memory"), :data => @mem_free },
                      { :label => _("used memory"), :data => used_memory } ],
      :swap_usage => [ { :label => _("free swap"), :data => @swap_free },
                       { :label => _("used swap"), :data => used_swap } ]
    }
  end

  def chart_names(chart)
    extract_label = ->(c) { c[:label] }
    chart.map(&extract_label)
  end

  def chart_name_data(chart)
    chart.map(&:values)
  end

  def render_charts
    charts.map do |selector, chart|
      react_component('DonutChart',
                      :columns => chart_name_data(chart),
                      :groups => [chart_names(chart)],
                      :id => selector.to_s)
    end.join("\n").html_safe
  end

  def used_memory
    @mem_size - @mem_free
  end

  def used_swap
    @swap_size - @swap_free
  end
end
