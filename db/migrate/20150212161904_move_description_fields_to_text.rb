class MoveDescriptionFieldsToText < ActiveRecord::Migration[4.2]
  def change
    change_column :compute_resources, :description, :text
    change_column :operatingsystems, :description, :text
    change_column :lookup_keys, :description, :text
    change_column :mail_notifications, :description, :text
  end
end
