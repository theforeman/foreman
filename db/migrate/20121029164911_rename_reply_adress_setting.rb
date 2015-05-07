class RenameReplyAdressSetting < ActiveRecord::Migration
  def up
    execute "UPDATE settings SET name='email_reply_address' WHERE name='email_replay_adress'"
  end

  def down
    execute "UPDATE settings SET name='email_replay_address' WHERE name='email_reply_adress'"
  end
end
