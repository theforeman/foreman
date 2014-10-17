# EncOutput adds to_enc method to any class so you could convert object
# to representation that can be part of ENC
#   @interface.to_enc
#
# While this concern can be used in any class that implements #attributes method
# it usually used in ActiveRecord models
#
# By default no attribute is exported. You can adjust which attributes should be
# exported by overriding private method enc_attributes, that result array
# of keys to use from #attributes e.g.
#
#   private
#   def enc_attributes
#     super + %w(name ip)
#   end
#
# you may want to embed some association instead of foreign key. You can do this
# by overriding embed_associations private method. It should return array of
# associations name, e.g.
#
#   private
#   def embed_associations
#     super + %w(subnet)
#   end
#
# You may also need to apply some transformation of a value during ENC output.
# In such case you can register your transformation (any callable object,
# lambda is recommended) by using register_to_enc_transformation class method
#
# class MyClass
#  include EncOutput
#  attr_accessible :name
#
#  register_to_enc_transformation :name, lambda { |v| v.downcase }
#
#  def enc_attributes
#    super + %w(name)
#  end
# end
module EncOutput
  extend ActiveSupport::Concern

  def to_enc
    own_attributes = {}
    self.attributes.each do |k, v|
      own_attributes[k] = primitive_value(transform(k, v)) if enc_attributes.include?(k.to_s)
    end
    own_associations = embed_associations.map { |a| [a, self.send(a).try(:to_enc)] }

    Hash[own_attributes].merge(Hash[own_associations])
  end

  module ClassMethods
    def register_to_enc_transformation(attribute, transformation)
      @to_enc_transformations ||= {}.with_indifferent_access
      @to_enc_transformations[attribute] = transformation
    end

    def transformation(attribute)
      @to_enc_transformations ||= {}.with_indifferent_access
      @to_enc_transformations[attribute]
    end
  end

  private

  def transform(attribute, value)
    transformation = self.class.transformation(attribute)
    transformation.nil? ? value : transformation.call(value)
  end

  def primitive_value(value)
    case value
      when ActiveSupport::HashWithIndifferentAccess
        value.to_hash
      else
        value
    end
  end

  def enc_attributes
    []
  end

  def embed_associations
    []
  end
end
