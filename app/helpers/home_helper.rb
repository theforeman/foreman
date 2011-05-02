module HomeHelper

  def class_for_current_page(tab)
    controller_name =~ /#{tab.singularize}/i ? "current_page_item" : ""
  end

  def menu(tab, myBookmarks ,path = nil)
    path ||= eval("hash_for_#{tab}_path")
    b = myBookmarks.map{|b| b if b.controller == path[:controller]}.compact
    content_tag :li, :class => class_for_current_page(tab) do
        link_to_if_authorized(tab + (b.empty? ? "" : "<span>&nbsp;&#9660;</span>"), path) +
        render("bookmarks/list", :bookmarks => b)
    end
  end
end
