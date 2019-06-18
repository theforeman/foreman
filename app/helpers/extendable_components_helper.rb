module ExtendableComponentsHelper
  def slot(slot_id, multi = false)
    content_tag :div, nil, {id: slot_id} do
      mount_react_component('Slot', "##{slot_id}", { id: slot_id, multi: multi }.to_json, { flatten_data: true })
    end
  end
end
