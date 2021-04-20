module Types
  class Host < BaseObject
    model_class ::Host::Managed

    description 'A Host'

    global_id_field :id
    timestamps
    field :name, String
    field :build, Boolean
    field :managed, Boolean
    field :ip, String
    field :ip6, String
    field :path, resolver: Resolvers::Host::Path
    field :mac, String
    field :last_report, GraphQL::Types::ISO8601DateTime
    field :domain_name, String
    field :pxe_loader, String
    field :enabled, Boolean
    field :uuid, String
    field :power_status, resolver: Resolvers::Host::PowerStatus

    belongs_to :architecture, Types::Architecture
    belongs_to :compute_resource, Types::ComputeResource
    belongs_to :domain, Types::Domain
    belongs_to :ptable, Types::Ptable
    belongs_to :location, Types::Location
    belongs_to :organization, Types::Organization
    belongs_to :model, Types::Model
    belongs_to :operatingsystem, Types::Operatingsystem
    belongs_to :puppet_ca_proxy, Types::SmartProxy
    belongs_to :puppet_proxy, Types::SmartProxy
    belongs_to :medium, Types::Medium
    belongs_to :hostgroup, Types::Hostgroup
    belongs_to :owner, Types::UserOrUsergroupUnion
    belongs_to :subnet, Types::Subnet
    belongs_to :compute_profile, Types::ComputeProfile
    has_many :fact_names, Types::FactName
    has_many :fact_values, Types::FactValue
    has_many :reports, Types::ConfigReport
  end
end
