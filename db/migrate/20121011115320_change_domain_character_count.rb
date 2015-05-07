class ChangeDomainCharacterCount < ActiveRecord::Migration
  def up
    change_column :domains, :fullname, :string, :limit => 254
  end

  def down
    change_column :domains, :fullname, :string, :limit => 32
  end
end
