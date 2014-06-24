object resource = controller.get_resource

attributes :id

node(:errors) { resource.errors.to_hash }
node(:full_messages) { resource.errors.full_messages }
