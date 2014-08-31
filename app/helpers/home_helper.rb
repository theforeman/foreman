module HomeHelper

  def render_menu menu_name
    authorized_menu_actions(Menu::Manager.items(menu_name).children).map do |menu|
      items = authorized_menu_actions(menu.children)
      render "home/submenu", :menu_items => items, :menu_title => _(menu.caption), :menu_name => menu.name if items.any?
    end.join(' ').html_safe
  end

  def authorized_menu_actions(choices)
    last_item = Menu::Divider.new(:first_div)
    choices   = choices.map do |item|
      last_item = case item
                    when Menu::Divider
                      item unless last_item.is_a?(Menu::Divider) #prevent adjacent dividers
                    when Menu::Item
                      item if item.authorized?
                    when Menu::Toggle
                      item if item.authorized_children.size > 0
                  end
    end.compact
    choices.shift if choices.first.is_a?(Menu::Divider)
    choices.pop if choices.last.is_a?(Menu::Divider)
    choices
  end

  def menu_item_tag item
    content_tag(:li,
                link_to(_(item.caption), item.url, item.html_options.merge(:id => "menu_item_#{item.name}")),
                :class => "menu_tab_#{item.url_hash[:controller]}_#{item.url_hash[:action]}")
  end

  def org_switcher_title
    title = if Organization.current && Location.current
              Organization.current.to_label + "@" + Location.current.to_label
            elsif Organization.current
              Organization.current.to_label
            elsif Location.current
              Location.current.to_label
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
