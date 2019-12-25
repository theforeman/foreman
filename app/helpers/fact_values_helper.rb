module FactValuesHelper
  def fact_from(record)
    date_time_relative(record.updated_at)
  rescue
    _("N/A")
  end

  def fact_name(value, parent)
    value_name = name = value.name
    memo       = ''
    name.split(FactName::SEPARATOR).map do |current_name|
      memo = memo.empty? ? current_name : memo + FactName::SEPARATOR + current_name
      content_tag(:li) do
        if value.compose && current_name == name.split(FactName::SEPARATOR).last
          url = host_parent_fact_facts_path(:parent_fact => value_name, :host_id => params[:host_id] || value.host.name)
          link_to(icon_text('angle-down', '', :kind => 'fa', :title => _('Expand nested items')), url) + ' ' + create_fact_name_link(parent, current_name, params[:host_id], value, value_name, memo)
        else
          create_fact_name_link(parent, current_name, params[:host_id], value, value_name, memo)
        end
      end
    end.join.html_safe
  end

  def create_fact_name_link(parent, current_name, host_id, value, value_name, memo)
    return current_name if parent.present? && h(parent.name) == memo
    if value_name != memo || value.compose
      parameters = { :parent_fact => memo }
      url = host_parent_fact_facts_path(parameters.merge({ :host_id => host_id || value.host.name }))
      link_to(current_name, url,
        :title => _("Show all %s children fact values") % memo)
    else
      link_to(current_name, fact_values_path(:search => "name = #{value_name}"),
        :title => _("Show %s fact values for all hosts") % value_name)
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

  # Return fact icon image tag. Stub is used in some cases because
  # of legal requirements. Make sure to get legal advice prior
  # putting any logos into our git repository.
  def fact_origin_icon(origin, icon_path)
    image_tag(icon_path, title: origin, size: '16x16')
  end

  def fact_breadcrumbs
    breadcrumbs(
      items: [
        {
          caption: _("Facts Values"),
          url: (fact_values_path if authorized_for(hash_for_fact_values_path)),
        },
        {
          caption: params[:host_id],
        },
      ],
      resource_url: api_hosts_path(thin: true),
      switcher_item_url: host_facts_path(':name'),
      switchable: true
    )
  end

  def is_escaped_value(value)
    value != CGI.escapeHTML(value)
  end

  def escaped_warning_title
    _("contains special characters")
  end

  def escaped_warning_context
    _("Search may fail or give you wrong results since it contains special characters that are query keywords such as < and >")
  end

  def print_escape_warning(column)
    fact_contains_escaped_values
  end
end
