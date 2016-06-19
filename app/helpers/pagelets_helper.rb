module PageletsHelper
  def virtual_path
    @virtual_path
  end

  def pagelets_for(mountpoint)
    result = ["#{controller_name}/#{action_name}", virtual_path].uniq.map do |key|
      Pagelets::Manager.pagelets_at(key, mountpoint)
    end
    result.flatten.sort
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
      next unless pagelet.onlyif.call(opts[:subject], self)
      result += "<div id='#{pagelet.id}' class='tab-pane'>"
      result += render_pagelet(pagelet, opts)
      result += "</div>"
    end
    result.html_safe
  end

  def render_tab_header_for(mountpoint, opts = {})
    result = ""
    pagelets_for(mountpoint).each do |pagelet|
      next unless pagelet.onlyif.call(opts[:subject], self)
      result += "<li><a href='##{pagelet.id}' data-toggle='tab'>#{_(pagelet.name)}</a></li>"
    end
    result.html_safe
  end

  def render_pagelet(pagelet, opts = {})
    if pagelet.onlyif.call(opts[:subject], self)
      render(pagelet.partial, opts.merge!({ :pagelet => pagelet, controller_name.singularize.to_sym => opts[:subject] })).html_safe
    else
      "".html_safe
    end
  end
end
