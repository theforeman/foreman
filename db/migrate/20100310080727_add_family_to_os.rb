class AddFamilyToOs < ActiveRecord::Migration
  def self.up
    add_column :operatingsystems, :family_id, :integer

    Operatingsystem.reset_column_information

    for os in Operatingsystem.all
      case os.name
      when /RedHat|Centos|Fedora/i
        os.family_id = Family::FAMILIES.index :RedHat
      when /Solaris/i
        os.family_id = Family::FAMILIES.index :Solaris
      when /Debian|Ubuntu/i
        os.family_id = Family::FAMILIES.index :Debian
      when nil
        say "You have an Operatingsystem with a nil name!"
        say os.inspect
      else
        say "Unable to find the operating system family for #{os.name}"
        say "Please update this in the gui. If your family is not present"
        say "in the GUI then modify the file lib/familiy.rb and redo this migration"
      end
      os.save
    end
  end

  def self.down
    remove_column :operatingsystems, :family_id
  end
end
