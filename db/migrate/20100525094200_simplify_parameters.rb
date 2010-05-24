class SimplifyParameters < ActiveRecord::Migration
  def self.up
    remove_index  :parameters, [:host_id,      :type]
    remove_index  :parameters, [:hostgroup_id, :type]
    remove_index  :parameters, [:domain_id,    :type]

    rename_column :parameters, :host_id, :reference_id
    add_index     :parameters, [:reference_id, :type]

    Parameter.reset_column_information

    success = true
    for parameter in Parameter.all
      # There should be no Parameter objects. That is an abstract class.
      # The type is probably nil because this table was imported by prod2dev
      parameter.update_attribute :type, "HostParameter"   if parameter.type.nil? and parameter.reference_id
      parameter.update_attribute :type, "GroupParameter"  if parameter.type.nil? and parameter.hostgroup_id
      parameter.update_attribute :type, "DomainParameter" if parameter.type.nil? and parameter.domain_id
      parameter.update_attribute :type, "CommonParameter" if parameter.type.nil?

      if parameter.reference_id.nil? and parameter.type != "CommonParameter"
        parameter.reference_id = parameter.hostgroup_id || parameter.domain_id
        unless parameter.save
          say "Failed to migrate the parameter #{parameter.name}: " + parameter.errors.full_messages.join("\n")
          success = false
        end
      end
    end

    if success
      say "Everything migrated ok so we remove the old columns"
      remove_column :parameters, :hostgroup_id
      remove_column :parameters, :domain_id
    end

  end

  def self.down
    remove_index :parameters, [:reference_id, :type]

    add_column    :parameters, :domain_id,    :integer
    add_column    :parameters, :hostgroup_id, :integer
    rename_column :parameters, :reference_id, :host_id

    Parameter.reset_column_information

    for parameter in Parameter.all
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
