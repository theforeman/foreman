class RemoveTaxonomyAndOverrideFromFilter < ActiveRecord::Migration[7.0]
  def up
    TaxableTaxonomy.where(taxable_type: 'Filter').delete_all

    remove_column :filters, :override
    filters = Filter.where(role_id: Role.where(origin: nil).or(Role.where(builtin: 2)))
    filters.each do |filter|
      filter.enforce_inherited_taxonomies
      filter.update_column(:taxonomy_search, filter.taxonomy_search)
    end
  end

  def down
    add_column :filters, :override, :boolean, :default => false, :null => false
    filters = Filter.where(role_id: Role.where(origin: nil).or(Role.where(builtin: 2))).where(override: false).where(taxonomy_search: nil)
    filters.each do |filter|
      filter.enforce_inherited_taxonomies
      filter.update_column(:taxonomy_search, filter.taxonomy_search)
    end
  end
end
