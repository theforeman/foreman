class ChangeDomainCharacterCount < ActiveRecord::Migration[4.2]
  def up
    change_column :domains, :fullname, :string, :limit => 254
  end

  def down
    change_column :domains, :fullname, :string, :limit => 32
  end
end
