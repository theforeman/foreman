class SetEmptyFilterTaxonomySearchNil < ActiveRecord::Migration[6.0]
  def change
    Filter.where(taxonomy_search: '').update_all(taxonomy_search: nil)
  end
end
