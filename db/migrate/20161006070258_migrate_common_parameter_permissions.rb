class MigrateCommonParameterPermissions < ActiveRecord::Migration[4.2]
  class FakeFilter < ApplicationRecord
    self.table_name = 'filters'
  end

  def up
    all_new_permissions = Permission.where(:name => ['view_params', 'edit_params', 'create_params', 'destroy_params'])

    affected = Filter.includes(:permissions).where(:permissions => {:name => ['view_globals', 'edit_globals', 'create_globals', 'destroy_globals']})
    affected.each do |filter|
      new_names = filter.permissions.map { |old| old.name.sub(/globals/, 'params') }
      new_permissions = all_new_permissions.select do |new|
        new_names.include?(new.name)
      end

      fake_filter = FakeFilter.find(filter.id)
      new_search = "type = CommonParameter"
      new_search = '(' + filter.search + ') and ' + new_search if filter.search.present?
      fake_filter.update_attribute :search, new_search
      filter.permissions = new_permissions
    end

    Permission.where(:name => ['view_globals', 'edit_globals', 'create_globals', 'destroy_globals']).destroy_all
  end

  def down
    # we can't tell what if CommonParameter search was set by user or previous migration
  end
end
