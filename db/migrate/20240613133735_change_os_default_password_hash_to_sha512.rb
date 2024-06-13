class ChangeOsDefaultPasswordHashToSha512 < ActiveRecord::Migration[4.2]
  def up
    change_column_default :operatingsystems, :password_hash, 'SHA512'
  end

  def down
    change_column_default :operatingsystems, :password_hash, 'SHA256'
  end
end
