class AddActionsToNotificationBlueprint < ActiveRecord::Migration
  def change
    add_column :notification_blueprints, :actions, :text
  end
end
