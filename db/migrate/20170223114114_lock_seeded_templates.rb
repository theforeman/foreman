class LockSeededTemplates < ActiveRecord::Migration[4.2]
  def up
    Template.where(:name => seeded_template_names).update_all(:locked => true)
  end

  def down
    Template.where(:name => seeded_template_names).update_all(:locked => false)
  end

  def seeded_template_names
    (SeedHelper.provisioning_templates + SeedHelper.partition_tables_templates).map do |path|
      metadata = Template.parse_metadata(File.read(path))
      metadata["name"]
    end.compact
  end
end
