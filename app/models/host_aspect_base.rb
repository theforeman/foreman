class HostAspectBase < ActiveRecord::Base
  self.abstract_class = true

  def self.inherited(subclass)
    super
    subclass.class_eval do
      belongs_to_host :inverse_of => subclass.name.underscore.to_sym
    end
  end

  def write_attribute(attr_name, value)
    host_changed(attr_name, read_attribute(attr_name), value) if attr_name == 'host'
    super
  end

  private

  def host_changed(attr, old_val, new_val)
    super
    return unless new_val

    record = self.host.host_aspects.build
    record.execution_model = self
  end
end
