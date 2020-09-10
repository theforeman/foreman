class AddViewParamsToFiltersWithEdit < ActiveRecord::Migration[4.2]
  class FakeFiltering < ApplicationRecord
    self.table_name = 'filterings'
  end

  class FakeFilter < ApplicationRecord
    self.table_name = 'filters'
  end

  def up
    filters_to_update = Filter.joins(:permissions).where("permissions.name IN ('edit_params', 'create_params', 'destroy_params')").distinct
    view_params = Permission.where(:name => 'view_params', :resource_type => 'Parameter').first_or_create
    filters_to_update.each do |filter|
      FakeFiltering.create(:filter_id => filter.id, :permission_id => view_params.id)
    end

    viewer_role = Role.where(:name => 'Viewer')
    site_manager_role = Role.where(:name => 'Site manager')
    [viewer_role, site_manager_role].each do |role|
      if role.present? && Filtering.joins(:filter).where(:permission_id => view_params.id).where("filters.role_id = #{role.first.id}").empty?
        filter = FakeFilter.create(:role_id => role.first.id)
        FakeFiltering.create(:filter_id => filter.id, :permission_id => view_params.id)
      end
    end
  end

  def down
    view_params = Permission.where(:name => 'view_params').first

    if view_params.present?
      Filter.joins(:filterings).where(:role_id => Role.where(:name => ['Viewer', 'Site manager'])).where("filterings.permission_id = #{view_params.id}").destroy_all
      Filtering.where(:permission_id => view_params.id).delete_all
      view_params.delete
    end
  end
end
