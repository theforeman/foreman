class ChangeOsDefaultPasswordHash < ActiveRecord::Migration
  def up
    change_column_default :operatingsystems, :password_hash, 'SHA256'
  end

  def down
    change_column_default :operatingsystems, :password_hash, 'MD5'
  end
end
