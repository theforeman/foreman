module Types
  class ConfigReport < Types::Report
    description 'A Config Report'

    global_id_field :id
    field :metrics, Types::RawJson
    field :status, Types::RawJson
    field :origin, String
  end
end
