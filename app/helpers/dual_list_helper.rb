module DualListHelper
  def mount_dual_list(
    attr,
    super_name,
    associations,
    id: "dual-list-#{Foreman.uuid}",
    label: nil,
    input_name: "architecture[operatingsystem_ids][]"
  )
    association_name = attr || ActiveModel::Naming.plural(associations)
    associated_obj = super_name.send(association_name)
    selected_ids = associated_obj.map(&:id)
    items = AssociationAuthorizer.authorized_associations(associations.reorder(nil), nil).all

    props = {
      id: id,
      label: label,
      items: items,
      selectedIDs: selected_ids,
      inputName: input_name
    }.to_json

    container_class = "container-#{id}"
    content_tag(:div, nil, :class => container_class) +
    mount_react_component("DualList", ".#{container_class}", props, flatten_data: true)
  end
end
