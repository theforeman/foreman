module Types
  class LookupValue < BaseObject
    description 'Lookup Value'

    global_id_field :id
    timestamps
    field :match, String
    field :value, ::Types::RawJson
    field :omit, Boolean
  end
end
