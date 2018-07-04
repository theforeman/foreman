module SearchBarHelper
  def mount_search_bar(
    id,
    controller: auto_complete_controller_name,
    url: "#{auto_complete_controller_name}/auto_complete_search",
    search_query: params[:search],
    use_bookmarks: true,
    use_key_shortcuts: true
  )
    bookmarks = {}
    if use_bookmarks
      bookmarks = {
        url: api_bookmarks_path,
        canCreate: authorizer.can?(:create_bookmarks),
        documentationUrl: documentation_url("4.1.5Searching")
      }
    end
    mount_react_component('SearchBar', "##{id}", {
      controller: controller,
      autocomplete: {
        searchQuery: search_query,
        url: url,
        useKeyShortcuts: use_key_shortcuts
      },
      bookmarks: bookmarks
    }.to_json)
  end
end
