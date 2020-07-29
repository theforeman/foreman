module Types
  class Report < BaseObject
    timestamps
    belongs_to :host, Types::Host
    has_many :logs, Types::Log
  end
end
