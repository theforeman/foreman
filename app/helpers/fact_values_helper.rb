module FactValuesHelper
  def fact_from(record)
    _("%s ago") % time_ago_in_words(record.updated_at)
  rescue
    _("N/A")
  end

  def fact_name(value, parent)
    value_name = name = h(value.name)
    memo       = ''
    name       = name.split(FactName::SEPARATOR).map do |current_name|
      memo = memo.empty? ? current_name : memo + FactName::SEPARATOR + current_name
      if parent.present? && h(parent.name) == memo
        current_name
      else
        if value_name != memo || value.compose
          parameters = { :parent_fact => memo }
          url = host_parent_fact_facts_path(parameters.merge({ :host_id => params[:host_id] || value.host.name }))
          link_to(current_name, url,
                  :title => _("Show all %s children fact values") % memo)
        else
          link_to(current_name, fact_values_path(:search => "name = #{value_name}"),
                  :title => _("Show %s fact values for all hosts") % value_name)
        end
      end
    end.join(FactName::SEPARATOR).html_safe

    if value.compose
      url = host_parent_fact_facts_path(:parent_fact => value_name, :host_id => params[:host_id] || value.host.name)
      link_to(icon_text('plus-sign','', :title => _('Expand nested items')), url) + ' ' + content_tag(:span, name)
    else
      name
    end
  end

  def show_full_fact_value(fact_value)
    content_tag(:div, :class => 'replace-hidden-value') do
      link_to_function(icon_text('plus', '', :class => 'small'), 'replace_value_control(this)',
               :title => _('Show full value'),
               :class => 'replace-hidden-value pull-right') +
      content_tag(:span, :class => 'full-value') do
        fact_value
      end
    end.html_safe
  end

  def fact_origin_icon(origin)
    return origin if origin == 'N/A'
    image_tag(origin + ".png", :title => origin)
  end
end
