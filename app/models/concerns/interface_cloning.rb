module InterfaceCloning
  extend ActiveSupport::Concern
  # we keep the before update host object in order to compare changes
  def setup_clone(&block)
    return if new_record?
    @old = setup_object_clone(self, &block)
  end

  def setup_object_clone(object)
    clone = object.dup
    yield(clone) if block_given?
    # we can't assign using #attributes= because of mass-assign protected attributes (e.g. type)
    (object.changed_attributes.keys - ["updated_at"]).each do |key|
      clone.send "#{key}=", object.changed_attributes[key]
    end
    clone
  end
end
