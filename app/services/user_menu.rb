class UserMenu
  def menus
    menus_array = [
      Menu::Manager.to_hash(:top_menu),
      Menu::Manager.to_hash(:side_menu),
      Menu::Manager.to_hash(:admin_menu),
    ]
    menus_array << Menu::Manager.to_hash(:labs_menu) if Setting[:lab_features]
    menus_array << Menu::Manager.to_hash(:devel_menu) if Rails.env.development?
    menus_array
  end

  def generate
    menus.each_with_object([]) { |menu, memo| memo.concat submenu_items(menu) }
  end

  def submenu_items(menu)
    pluck_sub_menu_children(menu).each_with_object([]) do |child, memo|
      next memo unless child[:type] == :item
      memo << { :name => child[:name], :url => child[:url] }
      memo
    end
  end

  def pluck_sub_menu_children(menu)
    menu.each_with_object([]) { |sub_menu, memo| memo.concat(sub_menu[:children] || []) }
  end
end
