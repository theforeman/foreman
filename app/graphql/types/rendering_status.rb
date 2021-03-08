module Types
  class RenderingStatus < BaseObject
    model_class HostStatus::RenderingStatus

    description 'A Rendering Status'

    global_id_field :id
    field :status, Integer
    field :safemode_status, Integer
    field :unsafemode_status, Integer
    field :label, resolver: Resolvers::RenderingStatus::Label

    belongs_to :host, Types::Host
    has_many :combinations, Types::RenderingStatusCombination
  end
end
