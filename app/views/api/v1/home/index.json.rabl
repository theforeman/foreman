object false
child(:links => "links") do
  node(:bookmarks) { api_bookmarks_path }
  node(:status) { api_status_path }
end
