class RenameHostGroupMatchers < ActiveRecord::Migration[5.2]
  def up
    host_group_matchers = Setting.find_by_name('host_group_matchers_inheritance')
    matchers_inheritance = Setting.find_by_name('matchers_inheritance')
    return unless host_group_matchers.present? && matchers_inheritance.present?
    matchers_inheritance.update_attribute(
      :value,
      host_group_matchers.value
    )
    host_group_matchers.destroy
  end

  def down
    host_group_matchers = Setting.find_by_name('host_group_matchers_inheritance')
    matchers_inheritance = Setting.find_by_name('matchers_inheritance')
    host_group_matchers&.destroy
    matchers_inheritance.update(
      :name => 'host_group_matchers_inheritance'
    )
  end
end
