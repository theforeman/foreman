class AddReleaseFieldToOs < ActiveRecord::Migration[5.2]
  class Operatingsystem < ApplicationRecord
    self.inheritance_column = nil
  end

  def up
    add_column :operatingsystems, :release, :string, :limit => 16, :default => "", :null => false

    ok = true
    Operatingsystem.all.each do |os|
      if os.minor&.include?('.')
        minor_release_array = os.minor.split('.')
        minor = minor_release_array[0]
        release = minor_release_array[1]
        os.update_attribute :minor, minor
        os.update_attribute :release, release
        ok &&= os.valid?
      end
    end
    unless ok
      say "Failed to migrate all os.minor and os.release"
    end
  end

  def down
    ok = true
    Operatingsystem.all.each do |os|
      if os.release && os.release != ""
        minor = os.minor + "." + os.release
        os.update_attribute :minor, minor
        ok &&= os.valid?
      end
    end
    if ok
      remove_column :operatingsystems, :release
    else
      say "Failed to migrate all os.minor and os.release"
    end
  end
end
