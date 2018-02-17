class ChangeLabelToTitle < ActiveRecord::Migration[4.2]
  def change
    rename_column :hostgroups, :label, :title

    # migration 20131120225132 is run by the katello plugin that adds 'label' to taxonomies
    if ActiveRecord::Base.connection.migration_context.get_all_versions.include?(20131120225132)
      add_column :taxonomies, :title, :string, :limit => 255
    else
      rename_column :taxonomies, :label, :title
    end
    Taxonomy.reset_column_information
    execute "UPDATE taxonomies set title = name WHERE ancestry IS NULL"
    Taxonomy.unscoped.where("ancestry IS NOT NULL").each do |taxonomy|
      taxonomy.title = taxonomy.get_title
      taxonomy.save_without_auditing
    end
  end
end
