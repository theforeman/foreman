module SearchBarHelper
  def mount_search_bar(
    id,
    controller: auto_complete_controller_name,
    url: send("auto_complete_search_#{auto_complete_controller_name}_path"),
    search_query: params[:search],
    use_bookmarks: true,
    use_key_shortcuts: true,
    autocomplete_id: "searchBar"
  )
    bookmarks = {}
    if use_bookmarks
      bookmarks = {
        url: api_bookmarks_path,
        canCreate: authorizer.can?(:create_bookmarks),
        documentationUrl: documentation_url("4.1.5Searching")
      }
    end
    mount_react_component("SearchBar", "##{id}", {
      controller: controller,
      autocomplete: {
        searchQuery: search_query,
        url: url,
        useKeyShortcuts: use_key_shortcuts,
        id: autocomplete_id
      },
      bookmarks: bookmarks
    }.to_json)
  end

  def get_search_props(
    controller: auto_complete_controller_name,
    url: send("auto_complete_search_#{auto_complete_controller_name}_path"),
    search_query: params[:search],
    autocomplete_id: "searchBar"
  )
    bookmarks = {
      url: api_bookmarks_path,
      canCreate: authorizer.can?(:create_bookmarks),
      documentationUrl: documentation_url("4.1.5Searching")
    }
    {
      controller: controller,
      autocomplete: {
        searchQuery: search_query,
        url: url,
        id: autocomplete_id
      },
      bookmarks: bookmarks
    }
  end
end
