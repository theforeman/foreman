class ConvertVmAttrsToHash < ActiveRecord::Migration[5.1]
  def up
    say "Starting serialized attributes conversion, this can take long time based on data amount"
    say "Converting Nics, total: #{FakeNic.unscoped.count}"
    transform_batch_columns(FakeNic, [:attrs, :compute_attributes])

    say "Converting Compute Attributes, total: #{FakeComputeAttribute.unscoped.count}"
    transform_batch_columns(FakeComputeAttribute, [:vm_attrs])

    say "Converting Compute Resources, total #{FakeComputeResource.unscoped.count}"
    transform_batch_columns(FakeComputeResource, [:attrs])

    say "Converting Lookup Keys, total: #{FakeLookupKey.unscoped.count}"
    transform_batch_columns(FakeLookupKey, [:default_value])

    say "Converting Lookup Values, total: #{FakeLookupValue.unscoped.count}"
    transform_batch_columns(FakeLookupValue, [:value])

    say "All conversions finished"
  end

  YML_HASH = '!ruby/hash:ActiveSupport::HashWithIndifferentAccess'
  YML_PARAMS = /!ruby\/[\w-]+:ActionController::Parameters/

  def transform_batch_columns(base, serialized_columns)
    base.unscoped.select(serialized_columns + [:id]).find_each do |object|
      serialized_columns.each do |column|
        attributes = object.send :read_attribute_before_type_cast, column
        next if attributes.nil?
        object.update_column(column, attributes) if attributes.gsub!(YML_PARAMS, YML_HASH)
      end
    end
  end

  class FakeNic < ApplicationRecord
    self.table_name = 'nics'
    self.inheritance_column = nil
  end

  class FakeComputeAttribute < ApplicationRecord
    self.table_name = 'compute_attributes'
  end

  class FakeComputeResource < ApplicationRecord
    self.table_name = 'compute_resources'
    self.inheritance_column = nil
  end

  class FakeLookupValue < ApplicationRecord
    self.table_name = 'lookup_values'
  end

  class FakeLookupKey < ApplicationRecord
    self.table_name = 'lookup_keys'
    self.inheritance_column = nil
  end
end
