class AddMetadataToTemplate < ActiveRecord::Migration[5.1]
  def up
    add_column :templates, :imported_metadata, :text

    Template.unscoped.each do |template|
      template.class.without_auditing do
        template.extract_metadata_from_template.save!
      end
    end
  end

  def down
    Template.without_auditing do
      Template.unscoped.each do |template|
        template.template = template.metadata + "\n" + template.template
        template.save!
      end
    end
    remove_column :templates, :imported_metadata
  end
end
