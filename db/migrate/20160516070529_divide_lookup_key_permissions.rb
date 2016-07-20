class DivideLookupKeyPermissions < ActiveRecord::Migration[4.2]
  class FakeFilter < ApplicationRecord
    self.table_name = 'filters'
    belongs_to :role
    has_many :filterings
    has_many :permissions
  end

  class FakeFiltering < ApplicationRecord
    self.table_name = 'filterings'
  end

  class FakePermission < ApplicationRecord
    self.table_name = 'permissions'
  end

  def up
    permissions_to_update = Permission.where(:name => ['view_external_variables', 'edit_external_variables', 'create_external_variables', 'destroy_external_variables'])
    permissions_to_update.update_all(:resource_type => 'VariableLookupKey')

    permissions_to_update.each do |original_permission|
      permission = FakePermission.where(:name => original_permission.name.sub('variables', 'parameters'), :resource_type => 'PuppetclassLookupKey').first_or_create
      Filtering.where('permission_id' => original_permission.id).distinct.each do |filtering|
        filter = FakeFilter.create(:search => filtering.filter.search, :role_id => filtering.filter.role_id,
                               :taxonomy_search => filtering.filter.taxonomy_search)
        FakeFiltering.create(:filter_id => filter.id, :permission_id => permission.id)
      end
    end
  end

  def down
    new_permission_names = ['view_external_parameters', 'edit_external_parameters', 'create_external_parameters', 'destroy_external_parameters']
    permissions_to_delete = Permission.where(:name => new_permission_names)
    filterings_to_delete = Filtering.where('permission_id' => permissions_to_delete.pluck(:id))
    filterings_ids = filterings_to_delete.pluck(:id)
    filterings_to_delete.delete_all
    Filter.joins(:filterings).where('filterings.id' => filterings_ids).delete_all
    permissions_to_delete.delete_all
    Permission.where(:name => ['view_external_variables', 'edit_external_variables', 'create_external_variables', 'destroy_external_variables'])
              .update_all(:resource_type => 'LookupKey')
  end
end
