class MoveSubjectToNotifications < ActiveRecord::Migration
  def change
    add_reference :notifications, :subject, polymorphic: true, index: true
    remove_reference :notification_blueprints, :subject, polymorphic: true, index: true
  end
end
