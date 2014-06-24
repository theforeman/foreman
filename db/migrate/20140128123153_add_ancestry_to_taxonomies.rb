class AddAncestryToTaxonomies < ActiveRecord::Migration
  def up
    add_column :taxonomies, :ancestry, :string
    add_index :taxonomies, :ancestry
    # migration 20131120225132 is run by the katello plugin that adds 'label' to taxonomies
    add_column(:taxonomies, :label, :string) unless ActiveRecord::Migrator.get_all_versions.include?(20131120225132)
  end

  def down
    remove_column :taxonomies, :ancestry
    remove_column(:taxonomies, :label) unless ActiveRecord::Migrator.get_all_versions.include?(20131120225132)
  end

end
