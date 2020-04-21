# Bookmarks
Bookmark.without_auditing do
  [
    { :name => "eventful", :query => "eventful = true", :controller => "config_reports" },
    { :name => "active", :query => 'last_report > "35 minutes ago" and (status.applied > 0 or status.restarted > 0)', :controller => "hosts" },
    { :name => "out of sync", :query => 'last_report < "30 minutes ago" and status.enabled = true', :controller => "hosts" },
    { :name => "error", :query => 'last_report > "35 minutes ago" and (status.failed > 0 or status.failed_restarts > 0 or status.skipped > 0)', :controller => "hosts" },
    { :name => "disabled", :query => 'status.enabled = false', :controller => "hosts" },
    { :name => "ok hosts", :query => 'last_report > "35 minutes ago" and status.enabled = true and status.applied = 0 and status.failed = 0 and status.pending = 0', :controller => "hosts" },
  ].each do |input|
    next if Bookmark.where(:controller => input[:controller], :name => input[:name]).exists?
    next if SeedHelper.audit_modified? Bookmark, input[:name], :controller => input[:controller]
    b = Bookmark.create({ :public => true }.merge(input))
    raise "Unable to create bookmark: #{format_errors b}" if b.nil? || b.errors.any?
  end
end
