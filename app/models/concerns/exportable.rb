# This concern makes it easy to export an ActiveRecord object with specified
# attributes and associations in a particular format.  If a specified
# assocation also includes this concern, then it will likewise be exported.
#
# Custom attributes can be specified with a custom export lambda in an options
# hash.
#
# Example:
#   attr_exportable :name, :address, :company => ->(user) { user.company.name }
#
module Exportable
  extend ActiveSupport::Concern

  def to_export(include_blank = true)
    return unless self.class.exportable_attributes.present?

    self.class.exportable_attributes.keys.inject({}) do |hash, attribute|

      value = export_attr(self.class.exportable_attributes[attribute], include_blank)
      # Rails considers false blank, but if a boolean value is explicitly set false, we want to ensure we export it.
      if include_blank || value.present? || value == false
        hash.update(attribute => value)
      else
        hash
      end
    end.stringify_keys
  end

  # Export a particular attribute or association.
  #   - If our exportable_attributes value is callable, we call it with self as an argument
  #   - If our object is iterable, then we export each item
  #   - If the attribute or association also includes this concern, call to_export on it
  def export_attr(exporter, include_blank)
    value = if exporter.respond_to?(:call)
              exporter.call(self)
            elsif respond_to?(exporter)
              send(exporter)
            end

    value = value.respond_to?(:map) ? export_iterable(value, include_blank) : value
    value.respond_to?(:to_export) ? value.to_export(include_blank) : value
  end

  # Exports each item in an iterable.  If it's a hash, then export each value.
  def export_iterable(items, include_blank)
    if items.is_a?(Hash)
      items.each { |key, value| items[key] = value.respond_to?(:to_export) ? value.to_export(include_blank) : value }
      items.to_hash.stringify_keys
    else
      items.map { |item| item.respond_to?(:to_export) ? item.to_export(include_blank) : item }
    end
  end

  module ClassMethods
    def exportable_attributes
      @exportable_attributes ||= {}
      (superclass.respond_to?(:exportable_attributes) && superclass.exportable_attributes) ? superclass.exportable_attributes.merge(@exportable_attributes) : @exportable_attributes.dup
    end

    # Takes an array of exportable attributes, and a custom exports hash.  The
    # custom exports hash should be a key/lambda pair used to export the
    # particular attribute.
    def attr_exportable(*args)
      @exportable_attributes ||= {}
      args.each do |arg|
        if arg.is_a?(Hash)
          @exportable_attributes.merge!(arg)
        else
          @exportable_attributes.merge!(arg => arg)
        end
      end
    end
  end
end
