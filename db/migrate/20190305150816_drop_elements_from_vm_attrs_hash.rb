class DropElementsFromVmAttrsHash < ActiveRecord::Migration[5.1]
  def up
    nics = FakeNic.unscoped.where("attrs like ? or compute_attributes like ?", "%elements:%", "%elements:%")
    if nics.count > 0
      say "Correcting serialized nics attributes, total #{nics.count}"
      nics.find_each do |nic|
        nic.attrs = drop_elements(nic.attrs)
        nic.compute_attributes = drop_elements(nic.compute_attributes)
        nic.save!(validate: false)
      end
    end

    attributes = FakeComputeAttribute.unscoped.where("vm_attrs like ?", "%elements:%")
    if attributes.count > 0
      say "Correcting serialized  vm attributes, total #{attributes.count}"
      attributes.find_each do |compute_attribute|
        compute_attribute.vm_attrs = drop_elements(compute_attribute.vm_attrs)
        compute_attribute.save!(validate: false)
      end
    end

    compute_resources = FakeComputeResource.unscoped.where("attrs like ?", "%elements:%")
    if compute_resources.count > 0
      say "Correcting serialized Compute Resources attributes, total #{compute_resources.count}"
      compute_resources.find_each do |compute_attribute|
        compute_attribute.attrs = drop_elements(compute_attribute.attrs)
        compute_attribute.save!(validate: false)
      end
    end

    lookup_keys = FakeLookupKey.unscoped.where("default_value like ?", "%elements:%")
    if lookup_keys.count > 0
      say "Correcting serialized Lookup Keys default values, total #{lookup_keys.count}"
      lookup_keys.find_each do |lk|
        lk.default_value = drop_elements(lk.default_value)
        lk.save!(validate: false)
      end
    end

    lookup_key_values = FakeLookupValue.unscoped.where("value like ?", "%elements:%")
    if lookup_key_values.count > 0
      say "Correcting serialized Lookup Keys value, total #{lookup_key_values.count}"
      lookup_key_values.find_each do |lv|
        lv.value = drop_elements(lv.value)
        lv.save!(validate: false)
      end
    end
  end

  def drop_elements(h)
    h = h['elements'] if h.key? 'elements'
    h.transform_values! { |v| v.is_a?(Hash) ? drop_elements(v) : v }
  end

  class FakeNic < ApplicationRecord
    self.table_name = 'nics'
    self.inheritance_column = nil
    serialize :compute_attributes, Hash
    serialize :attrs, Hash
  end

  class FakeComputeAttribute < ApplicationRecord
    self.table_name = 'compute_attributes'
    serialize :vm_attrs, Hash
  end

  class FakeComputeResource < ApplicationRecord
    self.table_name = 'compute_resources'
    self.inheritance_column = nil
    serialize :attrs, Hash
  end

  class FakeLookupValue < ApplicationRecord
    self.table_name = 'lookup_values'
    serialize :default_value, Hash
  end

  class FakeLookupKey < ApplicationRecord
    self.table_name = 'lookup_keys'
    self.inheritance_column = nil
    serialize :value, Hash
  end
end
