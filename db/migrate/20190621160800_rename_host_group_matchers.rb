class RenameHostGroupMatchers < ActiveRecord::Migration[5.2]
  def up
    host_group_matchers = Setting.where(name: 'host_group_matchers_inheritance')
    return unless host_group_matchers.exists?
    Setting.where(name: 'matchers_inheritance').update_all(
      value: host_group_matchers.pick(:value)
    )
    host_group_matchers.delete_all
  end

  def down
    Setting.where('host_group_matchers_inheritance').delete_all
    Setting.where('matchers_inheritance').update_all(
      name: 'host_group_matchers_inheritance'
    )
  end
end
