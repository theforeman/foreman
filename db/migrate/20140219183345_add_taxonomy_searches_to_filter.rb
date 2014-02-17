class AddTaxonomySearchesToFilter < ActiveRecord::Migration
  def self.up
    add_column :filters, :taxonomy_search, :text

    # to precache taxonomy search on all existing filters
    # setting may not exist yet
    flag = Setting::General.find_or_initialize_by_name('fix_db_cache',
                                                       :description   => 'Fix DB cache on next Foreman restart',
                                                       :settings_type => 'boolean', :default => false)
    flag.update_attributes :value => true

    Rake::Task['db:migrate'].enhance nil do
      Filter.reset_column_information
      Rake::Task['fix_db_cache'].invoke
    end
  end

  def self.down
    remove_column :filters, :taxonomy_search
  end
end
