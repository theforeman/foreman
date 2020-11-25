class RegenerateFiltersTaxonomySearches < ActiveRecord::Migration[5.2]
  def up
    Filter.where.not(:taxonomy_search => nil).find_each do |filter|
      filter.valid?
      filter.save! if filter.changed?
    end
  end
end
