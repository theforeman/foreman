class RenameReplyAdressSetting < ActiveRecord::Migration[4.2]
  def up
    execute "UPDATE settings SET name='email_reply_address' WHERE name='email_replay_adress'"
  end

  def down
    execute "UPDATE settings SET name='email_replay_address' WHERE name='email_reply_adress'"
  end
end
