module TrendsHelper
  include CommonParametersHelper

  def trendable_types
    options = {_('Environment') => 'Environment', _('Operating system') => 'Operatingsystem',
               _('Model') => 'Model', _('Facts') => 'FactName', _('Host group') => 'Hostgroup', _('Compute resource') => 'ComputeResource'}
    existing = ForemanTrend.types.pluck(:trendable_type)
    options.delete_if { |k, v| existing.include?(v) }
  end

  def trend_days_filter
    form_tag @trend, :id => 'days_filter', :method => :get, :class => "form form-inline" do
      content_tag(:span, (_("Trend of the last %s days.") %
                          select(nil, 'range', 1..Setting[:max_trend], {:selected => range},
                                 {:onchange => "$('#days_filter').submit();$(this).attr('disabled','disabled');;"})).html_safe)
    end
  end

  def trend_title(trend)
    if trend.fact_value.blank?
      trend.to_label
    else
      "#{trend.type_name} - #{trend.to_label}"
    end
  end

  def chart_data(trend, from = Setting[:max_trend], to = Time.now.utc)
    chart_colors = ['#4572A7', '#AA4643', '#89A54E', '#80699B', '#3D96AE', '#DB843D', '#92A8CD', '#A47D7C', '#B5CA92']
    values = trend.values
    labels = {}
    values.includes(:trendable).each {|v| labels[v.id] = [CGI.escapeHTML(v.to_label), trend_path(:id => v)]}
    values.includes(:trend_counters).where(["trend_counters.interval_end > ? or trend_counters.interval_end is null", from])
                                    .reorder("trend_counters.interval_start")
                                    .each_with_index.map do |value, idx|
      data = []
      value.trend_counters.each do |counter|
        # cut the left side of the graph
        interval_start = ((counter.interval_start || from) > from) ? counter.interval_start : from
        next_timestamp = counter.try(:interval_end) || Time.now.utc
        # transform the timestamp values to flot format - from seconds in Ruby to milliseconds in flot
        data << [interval_start.to_i * 1000, counter.count]
        data << [next_timestamp.to_i * 1000 - 1, counter.count]
      end
      {:label => labels[value.id][0], :href => labels[value.id][1], :data => data, :color => chart_colors[idx % chart_colors.size()] } unless data.empty?
    end.compact
  end

  def range
    params["range"].empty? ? Setting[:max_trend] : params["range"].to_i
  end
end
