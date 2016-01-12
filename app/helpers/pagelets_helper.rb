module PageletsHelper
  def pagelets_for(mountpoint)
    Pagelets::Manager.sorted_pagelets_at("#{controller_name}/#{action_name}", mountpoint)
  end

  def render_pagelets_for(mountpoint, opts = {})
    result = ""
    pagelets_for(mountpoint).each do |pagelet|
      result += render_pagelet(pagelet, opts)
    end
    result.html_safe
  end

  def render_tab_content_for(mountpoint, opts = {})
    result = ""
    pagelets_for(mountpoint).each do |pagelet|
      result += "<div id='#{pagelet.id}' class='tab-pane'>"
      result += render_pagelet(pagelet, opts)
      result +=  "</div>"
    end
    result.html_safe
  end

  def render_tab_header_for(mountpoint, opts = {})
    result = ""
    pagelets_for(mountpoint).each do |pagelet|
      result += "<li><a href='##{pagelet.id}' data-toggle='tab'>#{_(pagelet.name)}</a></li>"
    end
    result.html_safe
  end

  def render_pagelet(pagelet, opts)
    render(pagelet.partial, opts.merge!({ :pagelet => pagelet })).html_safe
  end
end
