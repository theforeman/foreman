class FakeComputeAttribute < ApplicationRecord
  self.table_name = 'compute_attributes'
  serialize :vm_attrs, Hash
end

class RemoveNewFromComputeAttributes < ActiveRecord::Migration[4.2]
  def up
    FakeComputeAttribute.all.each do |comp_attr|
      attrs_name = ['nics', 'interfaces'].find do |name|
        comp_attr.vm_attrs["#{name}_attributes"].present?
      end
      comp_attr.vm_attrs["#{attrs_name}_attributes"].delete("new_#{attrs_name}") if attrs_name
      comp_attr.vm_attrs['volumes_attributes'].try(:delete, 'new_volumes')
      comp_attr.save!
    end
  end

  def down
    # Cannot restore data
  end
end
