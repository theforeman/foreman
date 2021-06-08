module Types
  class ProvisioningTemplate < BaseObject
    description 'A Provisioning Template'

    global_id_field :id
    timestamps
    field :name, String
  end
end
