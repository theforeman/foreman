module StatisticsHelper
  def chart(stat)
    options = {:class => 'statistics-pie small', :expandable => true, :border => 0, :show_title => true}
    flot_pie_chart(stat.id, stat.title, stat.calculate, options.merge(:search => stat.search))
  end
end
