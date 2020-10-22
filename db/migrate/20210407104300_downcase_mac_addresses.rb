class DowncaseMacAddresses < ActiveRecord::Migration[6.0]
  def up
    execute 'UPDATE nics SET mac=LOWER(mac)'
  end

  def down
  end
end
