class AddAncestryToTaxonomies < ActiveRecord::Migration[4.2]
  def up
    add_column :taxonomies, :ancestry, :string, :limit => 255
    add_index :taxonomies, :ancestry
    # migration 20131120225132 is run by the katello plugin that adds 'label' to taxonomies
    add_column(:taxonomies, :label, :string, :limit => 255) unless ActiveRecord::Base.connection.migration_context.get_all_versions.include?(20131120225132)
  end

  def down
    remove_column :taxonomies, :ancestry
    remove_column(:taxonomies, :label) unless ActiveRecord::Base.connection.migration_context.get_all_versions.include?(20131120225132)
  end
end
