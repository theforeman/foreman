class ChangeConfigChartClass < ActiveRecord::Migration[6.0]
  def up
    Widget.where(template: 'status_chart_widget').find_each do |widget|
      widget.data ||= {}
      widget.data[:settings] ||= {}
      widget.data[:settings][:class_name] = 'host-configuration-chart-widget'
      widget.save
    end
  end
end
