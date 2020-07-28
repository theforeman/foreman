module Types
  class ConfigReport < BaseObject
    description 'A Config Report'

    global_id_field :id
    timestamps
    field :metrics, Types::RawJson
    field :status, Types::RawJson
    field :origin, String
    belongs_to :host, Types::Host
  end
end
