module FactValuesHelper

  def fact_from(record)
    _("%s ago") % time_ago_in_words(record.host.last_compile)
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
          if params[:host_id]
            url = host_facts_path(parameters.merge({ :host_id => params[:host_id] }))
          else
            url = fact_values_path(parameters)
          end
          link_to(current_name, url,
                  :title => _("Show all %s children fact values") % value_name)
        else
          link_to(current_name, fact_values_path("search" => "name = #{value_name}"),
                  :title => _("Show all %s fact values") % value_name)
        end
      end
    end.join(FactName::SEPARATOR).html_safe

    if value.compose
      link_to(icon_text('plus-sign','', :title => _('Expand nested items')),
              fact_values_path(:parent_fact => value_name)) + ' ' +
          content_tag(:span, name)
    else
      name
    end
  end
end
