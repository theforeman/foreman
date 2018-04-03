class ConvertVmAttrsToHash < ActiveRecord::Migration[5.1]
  def up
    transform ActionController::Parameters, :to_h
  end

  def down
    transform ActiveSupport::HashWithIndifferentAccess, :to_params
  end

  def transform(from, transform_method)
    ComputeAttributeHack.unscoped.all.in_batches do |batch|
      batch.each do |comp_attr|
        attributes = comp_attr.vm_attrs
        if YAML.load(attributes).is_a? from
          comp_attr.vm_attrs = send transform_method, attributes
          comp_attr.save!
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

  class ComputeAttributeHack < ApplicationRecord
    self.table_name = 'compute_attributes'
  end
end
