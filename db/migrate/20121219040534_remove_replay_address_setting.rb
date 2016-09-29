class RemoveReplayAddressSetting < ActiveRecord::Migration
  def up
    execute "DELETE FROM settings WHERE name='email_replay_address'"
  end

  def down
  end
end
