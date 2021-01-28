module ExtendableComponentsHelper
  def slot(slot_id, multi = false, additional_props = {})
    react_component('Slot', { id: slot_id, multi: multi }.merge(additional_props))
  end
end
