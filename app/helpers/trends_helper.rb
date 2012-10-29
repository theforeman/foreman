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
      existing = Trend.group(:trendable_type).where(:fact_value => nil, :fact_name=> nil).map{|opt| opt.to_s}
      options.delete_if{ |k,v|  existing.include?(v) }
    end
    options
  end

  def trend_days_filter
    form_tag @trend, :id => 'days_filter', :method => :get, :class=>"form form-inline" do
        content_tag(:span, "Trend of the last ") +
        select(nil, 'range', 1..30, {:selected => @range}, {:class=>"span1", :onchange =>"$('#days_filter').submit();$(this).disabled();"}) +
        content_tag(:span, " days.")
      end
  end

  def trend_data(trends, range)
    trends.map do |trend|
      data = trend.chart_data(range)
      {:name => trend.to_s, :data =>data }  unless data.empty?
    end.compact
  end

end
