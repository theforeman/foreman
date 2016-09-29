module HomeHelper
  def render_menu(menu_name)
    authorized_menu_actions(Menu::Manager.items(menu_name).children).map do |menu|
      items = authorized_menu_actions(menu.children)
      render "home/submenu", :menu_items => items, :menu_title => _(menu.caption), :menu_name => menu.name if items.any?
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
        if item.authorized_children.size > 0
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
    html_options['data-no-turbolink'] = true if !item.turbolinks

    content_tag(:li,
                link_to(_(item.caption), item.url, item.html_options.merge(html_options)),
                :class => "menu_tab_#{item.url_hash[:controller]}_#{item.url_hash[:action]}")
  end

  def org_switcher_title
    org_current = truncate(Organization.current.to_label) if Organization.current
    loc_current = truncate(Location.current.to_label) if Location.current
    title = if org_current && loc_current
              org_current + "@" + loc_current
            elsif org_current
              org_current
            elsif loc_current
              loc_current
            else
              _("Any Context")
            end
    title
  end

  def user_header
    summary = avatar_image_tag(User.current, :class=>'avatar small') +
              "#{User.current.to_label} " + content_tag(:span, "", :class=>'caret')
    link_to(summary.html_safe, "#", :class => "dropdown-toggle", :'data-toggle'=>"dropdown", :id => "account_menu")
  end
end
