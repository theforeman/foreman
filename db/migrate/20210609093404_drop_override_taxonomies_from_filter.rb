class DropOverrideTaxonomiesFromFilter < ActiveRecord::Migration[6.0]
  def up
    perms = Permission.where(name: %w[view_filters create_filters edit_filters destroy_filters])
    filters = Filter.joins(:filterings).where(filterings: { permission_id: perms })
    filters.update_all(override: false)
    TaxableTaxonomy.where(taxable: filters).delete_all
  end
end
