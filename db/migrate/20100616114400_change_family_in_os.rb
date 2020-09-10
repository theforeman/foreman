class ChangeFamilyInOs < ActiveRecord::Migration[4.2]
  class Operatingsystem < ApplicationRecord; end

  def up
    add_column :operatingsystems, :type, :string, :limit => 16
    add_index :operatingsystems, :type

    Operatingsystem.reset_column_information

    families = ["Debian", "Redhat", "Solaris", "Suse", "Windows"]

    ok = true
    Operatingsystem.all.each do |os|
      if os.family_id
        say "Converting #{os.family_id} into #{families[os.family_id]}"
        os.update_attribute :type, families[os.family_id]
        ok &&= os.valid?
      end
    end
    if ok
      remove_column :operatingsystems, :family_id
    else
      say "Failed to migrate all os.family_ids to os.family"
    end
  end

  def down
    add_column :operatingsystems, :family_id, :integer

    Operatingsystem.reset_column_information

    families = Operatingsystem.families

    ok = true
    Operatingsystem.all.each do |os|
      if os.family
        say "Converting #{os.family} into #{families.index(os.family.to_s)}"
        os.update_attribute :family_id,     families.index(os.family.to_s)
        ok &&= os.valid?
      end
    end
    if ok
      remove_index :operatingsystems, :type
      remove_column :operatingsystems, :type
    else
      say "Failed to migrate all os.families to os.family_ids"
    end
  end
end
