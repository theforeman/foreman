module StatisticsHelper
  def charts
    options = {:class => "statistics-pie small", :expandable => true, :'border' => 0, :show_title => true}
    [
      flot_pie_chart("os_dist",_("OS Distribution"), @os_count, options.merge(:search => "os_title=~VAL~")),
      flot_pie_chart("env_dist",_("Environments Distribution"), @env_count, options.merge(:search => "environment=~VAL~")),
      flot_pie_chart("class_dist",_("Class Distribution"), @klass_count, options.merge(:search => "class=~VAL~")),
      flot_pie_chart("mem_usage",_("Average memory usage"), [{:label=>_("free memory"), :data=>@mem_free},{:label=>_("used memory"),:data=>@mem_size-@mem_free}], options),
      flot_pie_chart("swap_usage",_("Average swap usage"), [{:label=>_("free swap"), :data=>@swap_free},{:label=>_("used swap"), :data=>@swap_size-@swap_free}], options)
    ]
  end

  def stat_chart(statistic)
    options = {:class => "statistics-pie small", :expandable => true, :'border' => 0, :show_title => true}
    flot_pie_chart(statistic.value,_(statistic.name), FactValue.authorized(:view_facts).my_facts.count_each(statistic.value), options.merge(:search => "facts.#{statistic.value}=~VAL~"))
  end

  def stats_remove_select
    select_action_button(_("Remove Statistic"), {:id => 'remove_statistic'}, true,
      @statistic.map do |statistic|
        display_delete_if_authorized(hash_for_statistic_path(:id => statistic, :text => statistic.name).merge(:auth_object => statistic, :authorizer => authorizer), { :data => { :confirm => _("Delete %s?") % statistic.name }, :class => '' })
      end
    )
  end
end
