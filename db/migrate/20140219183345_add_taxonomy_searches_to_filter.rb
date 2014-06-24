class AddTaxonomySearchesToFilter < ActiveRecord::Migration
  def self.up
    add_column :filters, :taxonomy_search, :text

    # to precache taxonomy search on all existing filters
    CacheManager.set_cache_setting(true)

    Rake::Task['db:migrate'].enhance nil do
      Filter.reset_column_information
      Rake::Task['fix_db_cache'].invoke
    end
  end

  def self.down
    remove_column :filters, :taxonomy_search
  end
end
