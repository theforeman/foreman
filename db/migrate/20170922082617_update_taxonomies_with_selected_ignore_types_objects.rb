class UpdateTaxonomiesWithSelectedIgnoreTypesObjects < ActiveRecord::Migration[4.2]
  def up
    say "This Migration will take time for updating organization & location records with all objects of selected ignore_types."
    Rake::Task['taxonomy:update_taxonomy'].invoke
  end

  def down
  end
end
