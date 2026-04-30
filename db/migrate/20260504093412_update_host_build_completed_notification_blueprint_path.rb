class UpdateHostBuildCompletedNotificationBlueprintPath < ActiveRecord::Migration[7.0]
  def update_path(old_path, new_path)
    blueprint = NotificationBlueprint.find_by(name: 'host_build_completed')
    return unless blueprint && blueprint.actions['links'].present?

    links = blueprint.actions['links'].each do |link|
      if link['path_method'] == old_path
        link['path_method'] = new_path
      end
    end
    blueprint.update_column(:actions, {links: links})
  end

  def up
    update_path('host_path', 'host_details_page_path')
  end

  def down
    update_path('host_details_page_path', 'host_path')
  end
end
