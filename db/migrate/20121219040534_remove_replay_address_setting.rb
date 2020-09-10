class RemoveReplayAddressSetting < ActiveRecord::Migration[4.2]
  def up
    execute "DELETE FROM settings WHERE name='email_replay_address'"
  end

  def down
  end
end
