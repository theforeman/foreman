class ConvertVmAttrsToHash < ActiveRecord::Migration[5.1]
  def up
    transform ActionController::Parameters, :to_h
  end

  def down
    transform ActiveSupport::HashWithIndifferentAccess, :to_params
  end

  def transform(from, transform_method)
    say "Starting serialized attributes conversion, this can take long time based on data amount"
    say "Converting Compute Nics"
    transform_batch_columns(FakeNic, from, ['attrs', 'compute_attributes'], transform_method)
    say "Converting Compute Attributes"
    transform_batch_columns(FakeComputeAttribute, from, ['vm_attrs'], transform_method)
    say "Converting Compute Resources"
    transform_batch_columns(FakeComputeResource, from, ['attrs'], transform_method)
    say "Converting Compute Reports"
    transform_batch_columns(FakeReport, from, ['metrics'], transform_method)
    say "Converting Compute Taxonomies"
    transform_batch_columns(FakeTaxonomy, from, ['ignore_types'], transform_method)
    say "Converting Compute Lookup Keys"
    transform_batch_columns(FakeLookupKey, from, ['default_value'], transform_method)
    say "Converting Compute Lookup Values"
    transform_batch_columns(FakeLookupValue, from, ['value'], transform_method)
    say "All conversions finished"
  end

  def transform_batch_columns(base, from, serialized_columns, transform_method)
    base.unscoped.all.in_batches do |batch|
      batch.each do |object|
        serialized_columns.each do |column|
          attributes = object.send column
          next if attributes.nil?
          if YAML.load(attributes).is_a? from
            object.send("#{column}=", send(transform_method, attributes))
            object.save!
          end
        end
      end
    end
  end

  def to_h(attr)
    attr.gsub(yml_params_hash, yml_hash).gsub(yml_params_obj, yml_hash)
  end

  def to_params(attr)
    attr.gsub(yml_hash, yml_params_obj)
  end

  def yml_hash
    '!ruby/hash:ActiveSupport::HashWithIndifferentAccess'
  end

  def yml_params_hash
    '!ruby/hash:ActionController::Parameters'
  end

  def yml_params_obj
    '!ruby/object:ActionController::Parameters'
  end

  class FakeComputeAttribute < ApplicationRecord
    self.table_name = 'compute_attributes'
  end

  class FakeNic < ApplicationRecord
    self.table_name = 'nics'
    self.inheritance_column = nil
  end

  class FakeReport < ApplicationRecord
    self.table_name = 'reports'
    self.inheritance_column = nil
  end

  class FakeComputeResource < ApplicationRecord
    self.table_name = 'compute_resources'
    self.inheritance_column = nil
  end

  class FakeTaxonomy < ApplicationRecord
    self.table_name = 'taxonomies'
    self.inheritance_column = nil
  end

  class FakeLookupKey < ApplicationRecord
    self.table_name = 'lookup_keys'
    self.inheritance_column = nil
  end

  class FakeLookupValue < ApplicationRecord
    self.table_name = 'lookup_values'
  end
end
