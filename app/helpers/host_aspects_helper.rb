module HostAspectsHelper
  # override host's tabs to add all aspects as tabs
  def host_additional_views(host)
    base_tabs = load_aspects(host)
    base_tabs.merge!(helper_tabs(host))
    base_tabs
  end

  def load_aspects(host)
    Hash[host.host_aspects_with_definitions.map do |aspect, definition|
      [definition.name, aspect]
    end]
  end

  def helper_tabs(host)
    tab_definitions = {}
    host.host_aspects_with_definitions.each do |aspect, aspect_definition|
      if aspect_definition.tabs.is_a? Hash
        tab_definitions.merge!(aspect_definition.tabs)
      else
        method_result = send(aspect_definition.tabs, host)
        tab_definitions.merge!(method_result)
      end
    end
    tab_definitions
  end
end
