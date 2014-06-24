class RemoveReplayAddressSetting < ActiveRecord::Migration
  def self.up
    execute "DELETE FROM settings WHERE name='email_replay_address'"
  end

  def self.down
  end
end
