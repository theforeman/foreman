class SimplifyParameters < ActiveRecord::Migration[4.2]
  def up
    remove_index  :parameters, [:host_id,      :type] if index_exists? :parameters, :host_id
    remove_index  :parameters, [:hostgroup_id, :type] if index_exists? :parameters, :hostgroup_id
    remove_index  :parameters, [:domain_id,    :type] if index_exists? :parameters, :domain_id

    rename_column :parameters, :host_id, :reference_id if column_exists? :parameters, :host_id
    add_index     :parameters, [:reference_id, :type] if index_exists? :parameters, :reference_id

    Parameter.reset_column_information

    success = true
    Parameter.all.each do |parameter|
      # There should be no Parameter objects. That is an abstract class.
      # The type is probably nil because this table was imported by prod2dev
      parameter.update_attribute :type, "HostParameter"   if column_exists?(:parameters, :reference_id) && parameter.type.nil? && parameter.reference_id
      parameter.update_attribute :type, "GroupParameter"  if column_exists?(:parameters, :hostgroup_id) && parameter.type.nil? && parameter.hostgroup_id
      parameter.update_attribute :type, "DomainParameter" if column_exists?(:parameters, :domain_id) && parameter.type.nil? && parameter.domain_id
      parameter.update_attribute :type, "CommonParameter" if parameter.type.nil?

      if parameter.reference_id.nil? && parameter.type != "CommonParameter"
        parameter.reference_id = parameter.hostgroup_id || parameter.domain_id
        unless parameter.save
          say "Failed to migrate the parameter #{parameter.name}: " + parameter.errors.full_messages.join("\n")
          success = false
        end
      end
    end

    if success
      say "Everything migrated ok so we remove the old columns"
      remove_column :parameters, :hostgroup_id if column_exists? :parameters, :hostgroup_id
      remove_column :parameters, :domain_id    if column_exists? :parameters, :domain_id
    end
  end

  def down
    remove_index :parameters, [:reference_id, :type]

    add_column    :parameters, :domain_id,    :integer
    add_column    :parameters, :hostgroup_id, :integer
    rename_column :parameters, :reference_id, :host_id

    Parameter.reset_column_information

    Parameter.all.each do |parameter|
      if parameter.type =~ /Group|Domain/
        parameter.hostgroup_id = parameter.host_id if parameter.type == "GroupParameter"
        parameter.domain_id    = parameter.host_id if parameter.type == "DomainParameter"
        parameter.host_id      = nil
        unless parameter.save
          say "Failed to migrate the parameter #{parameter.name}: " + parameter.errors.full_messages.join("\n")
        end
      end
    end

    add_index :parameters, [:host_id, :type]
    add_index :parameters, [:hostgroup_id, :type]
    add_index :parameters, [:domain_id, :type]
  end
end
