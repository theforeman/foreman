class IgnoreTaxonomiesForAuditFilters < ActiveRecord::Migration[5.2]
  def up
    unless (permission = Permission.find_by_name('view_audit_logs'))
      permission.filters.uniq.each do |filter|
        next if filter.role.locked?

        filter.organizations = []
        filter.locations = []
        filter.override = false
        filter.taxonomy_search = nil
        filter.save!
      end
    end
  end
end
