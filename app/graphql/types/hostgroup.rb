module Types
  class Hostgroup < BaseObject
    description 'A Hostgroup'

    global_id_field :id
    timestamps
    field :name, String
    field :title, String
    field :description, String

    belongs_to :architecture, Types::Architecture
    belongs_to :compute_resource, Types::ComputeResource
    belongs_to :domain, Types::Domain
    belongs_to :operatingsystem, Types::Operatingsystem
    belongs_to :puppet_ca_proxy, Types::SmartProxy
    belongs_to :puppet_proxy, Types::SmartProxy
    belongs_to :medium, Types::Medium
    belongs_to :ptable, Types::Ptable

    has_many :hosts, Types::Host
    has_many :locations, Types::Location
    has_many :organizations, Types::Organization

    belongs_to :parent, Types::Hostgroup, null: true, foreign_key: :parent_id
    field :children, Types::Hostgroup.connection_type, null: true, resolve: (proc do |object|
      RecordLoader.for(model_class).load_many(object.child_ids)
    end)

    field :descendants, Types::Hostgroup.connection_type, null: true, resolve: (proc do |object|
      RecordLoader.for(model_class).load_many(object.descendant_ids)
    end)
  end
end
