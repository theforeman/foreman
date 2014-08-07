class AddOsHashToConfigTemplate < ActiveRecord::Migration
  def up
    add_column :config_templates, :os_hash, :text

    ConfigTemplate.all.each do |template|
      template.send(:set_os_hash)
      template.save!
    end
  end

  def down
    remove_column :config_templates, :os_hash
  end
end
