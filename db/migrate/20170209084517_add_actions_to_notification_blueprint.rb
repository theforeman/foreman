class AddActionsToNotificationBlueprint < ActiveRecord::Migration[4.2]
  def change
    add_column :notification_blueprints, :actions, :text
  end
end
