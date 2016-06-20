class AddViewParamsToFiltersWithEdit < ActiveRecord::Migration
  def up
    filters_to_update = Filter.joins(:permissions).where("permissions.name IN ('edit_params', 'create_params', 'destroy_params')").uniq
    view_params = Permission.where(:name => 'view_params', :resource_type => 'Parameter').first_or_create
    filters_to_update.each do |filter|
      Filtering.create(:filter_id => filter.id, :permission_id => view_params.id)
    end

    viewer_role = Role.where(:name => 'Viewer')
    if viewer_role.present? && Filtering.joins(:filter).where(:permission_id => view_params.id).where("filters.role_id = #{viewer_role.first.id}").empty?
      Filter.create(:role_id => viewer_role.first.id, :permission_ids => [view_params.id])
    end
  end

  def down
    view_params = Permission.where(:name => 'view_params').first

    if view_params.present?
      Filter.joins(:filterings).where(:role_id => Role.where(:name => 'Viewer')).where("filterings.permission_id = #{view_params.id}").destroy_all
      Filtering.where(:permission_id => view_params.id).delete_all
      view_params.delete
    end
  end
end
