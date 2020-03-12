module ExtendableComponentsHelper
  def slot(slot_id, multi = false, additional_props = {})
    content_tag :div, nil, {id: slot_id} do
      mount_react_component('Slot', "##{slot_id}", { id: slot_id, multi: multi }.merge(additional_props).to_json, { flatten_data: true })
    end
  end
end
