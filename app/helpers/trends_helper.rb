module TrendsHelper

  include CommonParametersHelper

  def trendable_types new_record
    options = {_('Environment') => 'Environment', _('Operating System') => 'Operatingsystem',
     _('Model') => 'Model', _('Facts') =>'FactName',_('Host Group') => 'Hostgroup', _('Compute Resource') => 'ComputeResource'}
    if new_record
      existing = ForemanTrend.includes(:trendable).types.map(&:to_s)
      options.delete_if{ |k,v|  existing.include?(v) }
    end
    options
  end

  def trend_days_filter
    form_tag @trend, :id => 'days_filter', :method => :get, :class=>"form form-inline" do
        content_tag(:span, _("Trend of the last")) + ' '
        select(nil, 'range', 1..Setting.max_trend, {:selected => range}, {:class=>"span1", :onchange =>"$('#days_filter').submit();$(this).disabled();"}) +
        content_tag(:span, ' ' + _("days."))
      end
  end

  def trend_title trend
    if trend.fact_value.blank?
      trend.to_label
    else
      "#{trend.type_name} - #{trend.to_label}"
    end
  end

  def chart_data trend, from = Setting.max_trend, to = Time.now
    chart_colors = ['#4572A7','#AA4643','#89A54E','#80699B','#3D96AE','#DB843D','#92A8CD','#A47D7C','#B5CA92']
    values = trend.values
    labels = {}
    values.includes(:trendable).each {|v| labels[v.id] = [v.to_label, trend_path(:id => v)]}
    values.includes(:trend_counters).where(["trend_counters.created_at > ?", from]).reorder("trend_counters.created_at").each_with_index.map do |value, idx|
      data =  value.trend_counters.map { |t|  [t.created_at.to_i*1000, t.count]  }
      {:label => labels[value.id][0], :href=>labels[value.id][1], :data =>data, :color => chart_colors[idx % chart_colors.size()] } unless data.empty?
    end.compact
  end

  def range
    params["range"].empty? ? Setting.max_trend : params["range"].to_i
  end

end
