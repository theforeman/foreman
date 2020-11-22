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
        url: main_app.api_bookmarks_path,
        canCreate: authorizer.can?(:create_bookmarks),
        documentationUrl: documentation_url("4.1.5Searching"),
      }
    end
    react_component("SearchBar", {
                      data: {
                        controller: controller,
                      autocomplete: {
                        id: autocomplete_id,
                        searchQuery: search_query,
                        url: url,
                        useKeyShortcuts: use_key_shortcuts,
                      },
                      bookmarks: bookmarks,
                      }})
  end
end
