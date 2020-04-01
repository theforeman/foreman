class MigratePtablesToTemplates < ActiveRecord::Migration[4.2]
  class FakeOldPtable < ApplicationRecord
    self.table_name = 'ptables'

    has_and_belongs_to_many :operatingsystems, :join_table => 'operatingsystems_ptables', :foreign_key => 'ptable_id'
    has_many :hostgroups, :foreign_key => 'ptable_id'
    has_many_hosts :foreign_key => 'ptable_id'
  end

  class FakeNewPtable < ApplicationRecord
    self.table_name = 'templates'

    has_and_belongs_to_many :operatingsystems, :join_table => 'operatingsystems_ptables', :foreign_key => 'ptable_id'
    has_many :hostgroups, :foreign_key => 'ptable_id'
    has_many_hosts :foreign_key => 'ptable_id'
  end

  def up
    %w(operatingsystems_ptables hostgroups hosts).each do |source_table|
      if foreign_key_exists?(source_table, :name => "#{source_table}_ptable_id_fk")
        remove_foreign_key source_table, :name => "#{source_table}_ptable_id_fk"
      end
    end
    add_column :templates, :os_family, :string, :limit => 255

    FakeOldPtable.all.each do |old_ptable|
      say "migrating partition table #{old_ptable.name}"
      new_ptable = FakeNewPtable.new
      new_ptable.name = old_ptable.name
      new_ptable.template = old_ptable.layout
      new_ptable.os_family = old_ptable.os_family
      new_ptable.type = 'Ptable'
      new_ptable.operatingsystems = old_ptable.operatingsystems
      new_ptable.save!

      update_audits_hosts_and_hostgroups(old_ptable.id, new_ptable.id)
    end

    say 'deleting migrated partition tables'
    FakeOldPtable.all.each do |old_ptable|
      old_ptable.destroy
    end
    add_foreign_key 'operatingsystems_ptables', 'templates', :name => 'operatingsystems_ptables_ptable_id_fk', :column => 'ptable_id'
    add_foreign_key 'hostgroups', 'templates', :name => 'hostgroups_ptable_id_fk', :column => 'ptable_id'
    add_foreign_key 'hosts', 'templates', :name => 'hosts_ptable_id_fk', :column => 'ptable_id'
  end

  def down
    remove_foreign_key 'operatingsystems_ptables', :name => 'operatingsystems_ptables_ptable_id_fk'
    remove_foreign_key 'hostgroups', :name => 'hostgroups_ptable_id_fk'
    remove_foreign_key 'hosts', :name => 'hosts_ptable_id_fk'
    Ptable.all.each do |new_ptable|
      say "migrating partition table #{new_ptable.name} down"
      old_ptable = FakeOldPtable.new
      old_ptable.name = new_ptable.name
      old_ptable.layout = new_ptable.template
      old_ptable.os_family = new_ptable.os_family
      old_ptable.operatingsystems = new_ptable.operatingsystems
      old_ptable.save!

      update_audits_hosts_and_hostgroups(new_ptable.id, old_ptable.id)
    end

    say 'deleting migrated partition tables'
    Ptable.delete_all

    remove_column :templates, :os_family
    %w(operatingsystems_ptables hostgroups hosts).each do |source_table|
      add_foreign_key source_table, 'ptables', :name => "#{source_table}_ptable_id_fk", :column => 'ptable_id'
    end
  end

  private

  def update_audits_hosts_and_hostgroups(old_id, new_id)
    Audit.where(:auditable_type => 'Ptable', :auditable_id => old_id).update_all(:auditable_id => new_id)

    Host::Managed.where(:ptable_id => old_id).update_all(:ptable_id => new_id)
    Hostgroup.where(:ptable_id => old_id).update_all(:ptable_id => new_id)
  end
end
