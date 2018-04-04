class AddReleasenameToOs < ActiveRecord::Migration[4.2]
  class Operatingsystem < ApplicationRecord; end

  def up
    add_column :operatingsystems, :release_name, :string, :limit => 64

    Operatingsystem.reset_column_information

    if (os = Operatingsystem.find_by_name_and_major_and_minor("Ubuntu", "9", "04"))
      os.update :release_name => "jaunty", :family_id => 0
    end
    if (os = Operatingsystem.find_by_name_and_major_and_minor("Ubuntu", "9", "10"))
      os.update :release_name => "karmic", :family_id => 0
    end
    if (os = Operatingsystem.find_by_name_and_major_and_minor("Ubuntu", "10", "04"))
      os.update :release_name => "lucid",  :family_id => 0
    end
  end

  def down
    remove_column :operatingsystems, :release_name
  end
end
