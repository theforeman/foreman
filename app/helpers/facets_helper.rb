module FacetsHelper
  # override host's tabs to add all facets as tabs
  def host_additional_views(host)
    base_tabs = load_facets(host)
    base_tabs.merge!(helper_tabs(host))
    base_tabs
  end

  def load_facets(host)
    Hash[host.host_facets_with_definitions.map do |facet, definition|
      [definition.name, facet]
    end]
  end

  def helper_tabs(host)
    tab_definitions = {}
    host.host_facets_with_definitions.each do |facet, facet_definition|
      if facet_definition.tabs.is_a? Hash
        tab_definitions.merge!(facet_definition.tabs)
      else
        method_result = send(facet_definition.tabs, host)
        tab_definitions.merge!(method_result)
      end
    end
    tab_definitions
  end
end
