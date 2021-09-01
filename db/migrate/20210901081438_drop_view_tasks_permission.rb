class DropViewTasksPermission < ActiveRecord::Migration[6.0]
  def up
    Permission.where(name: 'view_tasks').destroy_all
    # clean up any empty filters left behind
    Filter.where.not(id: Filtering.distinct.select(:filter_id)).destroy_all
  end

  def down
    # The permission will get recreated by seeds
  end
end
