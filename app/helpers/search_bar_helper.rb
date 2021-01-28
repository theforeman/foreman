module SearchBarHelper
  def mount_search_bar
    bookmarks = {
      url: main_app.api_bookmarks_path,
      canCreate: authorizer.can?(:create_bookmarks),
      documentationUrl: documentation_url("4.1.5Searching"),
    }
    url = send("auto_complete_search_#{auto_complete_controller_name}_path")
    react_component("SearchBar", data: {
                      controller: auto_complete_controller_name,
                      autocomplete: {
                        id: 'searchBar',
                        searchQuery: params[:search],
                        url: url,
                        useKeyShortcuts: true,
                      },
                      bookmarks: bookmarks,
                    })
  end
end
