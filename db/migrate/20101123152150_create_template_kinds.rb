class CreateTemplateKinds < ActiveRecord::Migration
  def self.up
    create_table :template_kinds do |t|
      t.string :name

      t.timestamps
    end
    TemplateKind.reset_column_information

    %w[PXELinux gPXE provision finish script].each do |type|
      TemplateKind.create(:name => type)
    end
  end

  def self.down
    drop_table :template_kinds
  end
end
