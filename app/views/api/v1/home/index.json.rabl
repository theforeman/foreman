object false
child(:links => "links") do
  node(:status) { api_status_path }

  %w(bookmarks architectures operatingsystems).each do |name|
    node(name.to_sym) { send :"api_#{name}_path" }
  end
end
