module HostStatus
  class RenderingStatusCombination < ::ApplicationRecord
    include Authorizable

    graphql_type '::Types::RenderingStatusCombination'

    OK = 0
    WARN = 1
    ERROR = 2

    belongs_to_host
    belongs_to :template, class_name: 'ProvisioningTemplate'
    belongs_to :host_status, inverse_of: :combinations,
                             class_name: 'HostStatus::RenderingStatus',
                             primary_key: :host_id,
                             foreign_key: :host_id

    validates :host, uniqueness: { scope: :template }
    validates :host, presence: true
    validates :template, presence: true
  end
end
