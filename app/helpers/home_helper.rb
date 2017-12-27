module HomeHelper
  def render_vertical_menu(menu_name, mobile = false)
    authorized_menu_actions(Menu::Manager.items(menu_name).children).map do |menu|
      items = authorized_menu_actions(menu.children)
      render "home/vertical_menu", :menu_items => items, :menu_title => _(menu.caption), :menu_icon => menu.icon,
                                   :menu_name => menu.name, :mobile_class => mobile ? 'visible-xs-block' : ''  if items.any?
    end.join(' ').html_safe
  end

  def authorized_menu_actions(choices)
    last_shown_item_was_divider = true

    choices = choices.map do |item|
      case item
      when Menu::Divider
        unless last_shown_item_was_divider
          last_shown_item_was_divider = true
          item
        end
      when Menu::Item
        if item.authorized?
          last_shown_item_was_divider = false
          item
        end
      when Menu::Toggle
        unless item.authorized_children.empty?
          last_shown_item_was_divider = false
          item
        end
      end
    end.compact

    choices.shift if choices.first.is_a?(Menu::Divider)
    choices.pop if choices.last.is_a?(Menu::Divider)
    choices
  end

  def menu_item_tag(item)
    html_options = {:id => "menu_item_#{item.name}"}
    html_options['data-no-turbolink'] = true unless item.turbolinks

    content_tag(:li,
                link_to(_(item.caption), item.url, item.html_options.merge(html_options)),
                :class => "menu_tab_#{item.url_hash[:controller]}_#{item.url_hash[:action]}")
  end

  def menu_secondary_item(item)
    html_options = {:id => "menu_item_#{item.name}"}
    html_options['data-no-turbolink'] = true unless item.turbolinks

    content_tag(:li,
                link_to(content_tag(:span, _(item.caption), :class => "list-group-item-value").html_safe, item.url, item.html_options.merge(html_options)),
                :class => "list-group-item")
  end

  def taxonomies_menu(item)
    html_options = {:id => "menu_item_#{item[:name]}"}

    content_tag(:li,
                link_to(content_tag(:span, _(item[:caption]), :class => "list-group-item-value").html_safe, item[:url], html_options),
                :class => "list-group-item")
  end

  def tax_title(tax)
    current_tax = tax.humanize.constantize.current
    return _("Any #{tax.humanize}") unless current_tax
    truncate(current_tax.to_label)
  end

  def user_header
    summary = avatar_image_tag(User.current, :class=>'avatar small') +
              "#{User.current.to_label} " + content_tag(:span, "", :class=>'caret')
    link_to(summary.html_safe, "#", :class => "dropdown-toggle nav-item-iconic", :'data-toggle'=>"dropdown", :id => "account_menu")
  end
end
