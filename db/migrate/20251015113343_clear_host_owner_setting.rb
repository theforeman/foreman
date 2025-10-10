class ClearHostOwnerSetting < ActiveRecord::Migration[7.0]
  def up
    OwnerClassifier.classify_owner(Setting[:host_owner])
  rescue ActiveRecord::RecordNotFound # maybe general rescue to clear at any error?
    Foreman.settings.set_user_value('host_owner', '').save
  end

  def down
  end
end
