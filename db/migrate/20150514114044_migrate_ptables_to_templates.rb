class MigratePtablesToTemplates < ActiveRecord::Migration[4.2]
  def up
    %w(operatingsystems_ptables hostgroups hosts).each do |source_table|
      if foreign_key_exists?(source_table, :name => "#{source_table}_ptable_id_fk")
        remove_foreign_key source_table, :name => "#{source_table}_ptable_id_fk"
      end
    end
    add_column :templates, :os_family, :string, :limit => 255

    add_foreign_key 'operatingsystems_ptables', 'templates', :name => 'operatingsystems_ptables_ptable_id_fk', :column => 'ptable_id'
    add_foreign_key 'hostgroups', 'templates', :name => 'hostgroups_ptable_id_fk', :column => 'ptable_id'
    add_foreign_key 'hosts', 'templates', :name => 'hosts_ptable_id_fk', :column => 'ptable_id'
  end

  def down
    remove_foreign_key 'operatingsystems_ptables', :name => 'operatingsystems_ptables_ptable_id_fk'
    remove_foreign_key 'hostgroups', :name => 'hostgroups_ptable_id_fk'
    remove_foreign_key 'hosts', :name => 'hosts_ptable_id_fk'

    remove_column :templates, :os_family
    %w(operatingsystems_ptables hostgroups hosts).each do |source_table|
      add_foreign_key source_table, 'ptables', :name => "#{source_table}_ptable_id_fk", :column => 'ptable_id'
    end
  end
end
