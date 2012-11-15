module TrendsHelper

  include CommonParametersHelper

  def trend_chart name, title, subtitle, data, options = {}
    content_tag(:div, nil,
                { :id             => name,
                  :class          => 'trend_chart',
                  :'chart-name'   => name,
                  :'chart-title'  => title,
                  :'chart-subtitle'  => subtitle,
                  :'chart-data-hostcount'  => data.to_a.to_json
                }.merge(options))
  end

  def trendable_types new_record
    options = {'Environment' => 'Environment', 'Operating System' => 'Operatingsystem',
     'Model' => 'Model', 'Facts' =>'FactName','Host Group' => 'Hostgroup', 'Compute Resource' => 'ComputeResource'}
    if new_record
      existing = ForemanTrend.includes(:trendable).types.map(&:to_s)
      options.delete_if{ |k,v|  existing.include?(v) }
    end
    options
  end

  def trend_days_filter
    form_tag @trend, :id => 'days_filter', :method => :get, :class=>"form form-inline" do
        content_tag(:span, "Trend of the last ") +
        select(nil, 'range', 1..30, {:selected => range}, {:class=>"span1", :onchange =>"$('#days_filter').submit();$(this).disabled();"}) +
        content_tag(:span, " days.")
      end
  end

  def trend_title trend
    if trend.fact_value.blank?
      trend.to_label.camelcase
    else
      "#{trend.type_name.camelcase} - #{trend.to_label}"
    end
  end

  def chart_data trend, from = 30.day.ago, to = Time.now
    values = trend.values
    labels = {}
    values.includes(:trendable).each {|v| labels[v.id] = v.to_label}

    values.includes(:trend_counters).where(["trend_counters.created_at > ?", from]).order("trend_counters.created_at").map do |value|
      data =  value.trend_counters.map { |t|  [t.created_at.to_i*1000, t.count]  }
      {:name => labels[value.id], :data =>data } unless data.empty?
    end.compact
  end

  def range
    params["range"].empty? ? 30 : params["range"].to_i
  end

end
