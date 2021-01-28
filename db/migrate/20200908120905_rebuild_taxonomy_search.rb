class RebuildTaxonomySearch < ActiveRecord::Migration[6.0]
  def up
    Filter.where.not(taxonomy_search: nil).find_in_batches do |filters|
      filters.each(&:save)
    end
  end
end
