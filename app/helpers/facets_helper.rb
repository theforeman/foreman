module FacetsHelper
  # override host's tabs to add all facets as tabs
  def facet_tabs(host)
    base_tabs = {}

    host.facets_with_definitions.each do |facet, facet_definition|
      facet_tabs = {}
      facet_tabs[facet_definition.name] = facet if lookup_context.find_all(facet.to_partial_path, [], true).any?

      facet_tabs.merge!(helper_tabs(host, facet_definition))

      base_tabs[facet_definition.name] = facet_tabs
    end

    base_tabs
  end

  private

  def helper_tabs(host, facet_definition)
    tab_definitions = {}
    return tab_definitions unless facet_definition.tabs

    if facet_definition.tabs.is_a? Hash
      tab_definitions.merge!(facet_definition.tabs)
    else
      method_result = send(facet_definition.tabs, host)
      tab_definitions.merge!(method_result)
    end
    tab_definitions
  end
end
