module Types
  class RenderingStatusCombination < BaseObject
    model_class HostStatus::RenderingStatusCombination

    description 'A Rendering Status Combination'

    global_id_field :id
    timestamps
    field :safemode_status, Integer
    field :unsafemode_status, Integer

    belongs_to :host, Types::Host
    belongs_to :template, Types::ProvisioningTemplate
  end
end
