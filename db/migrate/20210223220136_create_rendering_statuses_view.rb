class CreateRenderingStatusesView < ActiveRecord::Migration[6.0]
  def change
    create_view :rendering_statuses_view
  end
end
