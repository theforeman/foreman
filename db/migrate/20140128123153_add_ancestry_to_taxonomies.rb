class AddAncestryToTaxonomies < ActiveRecord::Migration
  def up
    add_column :taxonomies, :ancestry, :string
    add_index :taxonomies, :ancestry
    add_column :taxonomies, :label, :string

    Taxonomy.reset_column_information
    execute "UPDATE taxonomies set label = name WHERE ancestry IS NULL"
    Taxonomy.where("ancestry IS NOT NULL").each do |taxonomy|
      taxonomy.label = taxonomy.get_label
      taxonomy.save_without_auditing
    end
  end

  def down
    remove_column :taxonomies, :ancestry
    remove_index :taxonomies, :ancestry
    remove_column :taxonomies, :label
  end

end
