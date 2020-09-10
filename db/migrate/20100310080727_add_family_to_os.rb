class AddFamilyToOs < ActiveRecord::Migration[4.2]
  class Operatingsystem < ApplicationRecord; end

  def up
    add_column :operatingsystems, :family_id, :integer

    Operatingsystem.reset_column_information

    Operatingsystem.all.each do |os|
      case os.name
      when /RedHat|Centos|Fedora/i
        os.family_id = Operatingsystem::FAMILIES.index :RedHat
      when /Solaris/i
        os.family_id = Operatingsystem::FAMILIES.index :Solaris
      when /Debian|Ubuntu/i
        os.family_id = Operatingsystem::FAMILIES.index :Debian
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

  def down
    remove_column :operatingsystems, :family_id
  end
end
