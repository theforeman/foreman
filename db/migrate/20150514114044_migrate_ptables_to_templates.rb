class MigratePtablesToTemplates < ActiveRecord::Migration
  class FakeOldPtable < ActiveRecord::Base
    self.table_name = 'ptables'

    has_and_belongs_to_many :operatingsystems, :join_table => 'operatingsystems_ptables', :foreign_key => 'ptable_id'
    has_many :hostgroups, :foreign_key => 'ptable_id'
    has_many_hosts :foreign_key => 'ptable_id'
  end

  class FakeNewPtable < ActiveRecord::Base
    self.table_name = 'templates'

    has_and_belongs_to_many :operatingsystems, :join_table => 'operatingsystems_ptables', :foreign_key => 'ptable_id'
    has_many :hostgroups, :foreign_key => 'ptable_id'
    has_many_hosts :foreign_key => 'ptable_id'
  end

  def up
    if foreign_keys('operatingsystems_ptables').find { |f| f.options[:name] == 'operatingsystems_ptables_ptable_id_fk' }.present?
      remove_foreign_key "operatingsystems_ptables", :name => "operatingsystems_ptables_ptable_id_fk"
    end
    if foreign_keys('hostgroups').find { |f| f.options[:name] == 'hostgroups_ptable_id_fk' }.present?
      remove_foreign_key "hostgroups", :name => "hostgroups_ptable_id_fk"
    end
    if foreign_keys('hosts').find { |f| f.options[:name] == 'hosts_ptable_id_fk' }.present?
      remove_foreign_key "hosts",  :name => "hosts_ptable_id_fk"
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
      new_ptable.hostgroups = old_ptable.hostgroups
      new_ptable.save!

      Audit.where(:auditable_type => 'Ptable', :auditable_id => old_ptable.id).each do |audit|
        audit.update_attribute :auditable_id, new_ptable.id
      end

      old_ptable.hosts.each do |host|
        host.update_attribute :ptable_id, new_ptable.id
      end
    end

    say 'deleting migrated partition tables'
    FakeOldPtable.all.each do |old_ptable|
      old_ptable.destroy
    end
    add_foreign_key "operatingsystems_ptables", "templates", :name => "operatingsystems_ptables_ptable_id_fk", :column => 'ptable_id'
    add_foreign_key "hostgroups", "templates", :name => "hostgroups_ptable_id_fk", :column => 'ptable_id'
    add_foreign_key "hosts", "templates", :name => "hosts_ptable_id_fk", :column => 'ptable_id'
  end

  def down
    remove_foreign_key "operatingsystems_ptables", :name => "operatingsystems_ptables_ptable_id_fk"
    remove_foreign_key "hostgroups", :name => "hostgroups_ptable_id_fk"
    remove_foreign_key "hosts",  :name => "hosts_ptable_id_fk"
    Ptable.all.each do |new_ptable|
      say "migrating partition table #{new_ptable.name} down"
      old_ptable = FakeOldPtable.new
      old_ptable.name = new_ptable.name
      old_ptable.layout = new_ptable.template
      old_ptable.os_family = new_ptable.os_family
      old_ptable.operatingsystems = new_ptable.operatingsystems
      old_ptable.hostgroups = new_ptable.hostgroups
      old_ptable.save!

      Audit.where(:auditable_type => 'Ptable', :auditable_id => new_ptable.id).each do |audit|
        audit.update_attribute :auditable_id, old_ptable.id
      end

      new_ptable.hosts.each do |host|
        host.update_attribute :ptable_id, old_ptable.id
      end
    end

    say 'deleting migrated partition tables'
    Ptable.delete_all

    remove_column :templates, :os_family
    add_foreign_key "operatingsystems_ptables", "ptables", :name => "operatingsystems_ptables_ptable_id_fk", :column => 'ptable_id'
    add_foreign_key "hostgroups", "ptables", :name => "hostgroups_ptable_id_fk", :column => 'ptable_id'
    add_foreign_key "hosts", "ptables", :name => "hosts_ptable_id_fk", :column => 'ptable_id'
  end
end
