class FixFiltersWithMultipleResourceTypes < ActiveRecord::Migration
  def change
    filters_to_split = Filter.unscoped.joins(:permissions).group('filters.id', :resource_type).
                              having('min(resource_type) <> max(resource_type)').pluck(:id)
    Filter.unscoped.includes(:permissions).references(:permissions).where(:id => filters_to_split).
      each do |filter|
      next if filter.valid?
      if filter.errors[:permissions] == ['Permissions must be of same resource type']
        # If the filter was created long time ago, it may have had several
        # resources of the same type. To fix it, let's split it into different
        # filters each with its own resource type.
        filter.permissions.group_by(&:resource_type).each do |resource_type, permissions|
          # Create a new filter for all resource types
          restricted_resource_type_filter = Filter.new(
            :role => filter.role,
            :permissions => permissions,
            :taxonomy_search => filter.taxonomy_search,
            :organizations => filter.organizations,
            :locations => filter.locations,
            :override => filter.override
          )
          restricted_resource_type_filter.save
        end

        # At this point, all permissions are in their own filters by resource type
        filter.errors.clear
        filter.destroy
      end
    end
  end
end
