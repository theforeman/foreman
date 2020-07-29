module Types
  class Log < BaseObject
    description 'A Log'

    global_id_field :id
    field :level, String
    belongs_to :source, Types::Source
    belongs_to :message, Types::Message
    belongs_to :report, Types::Report
  end
end
