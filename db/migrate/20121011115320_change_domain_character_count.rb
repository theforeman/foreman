class ChangeDomainCharacterCount < ActiveRecord::Migration
  def self.up
    change_column :domains, :fullname, :string, :limit => 254
  end

  def self.down
    change_column :domains, :fullname, :string, :limit => 32
  end
end
