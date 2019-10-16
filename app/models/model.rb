class Model < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include ::Foreman::EventSubscribers::Observable

  notify_event_observers on: :create, with: :created
  notify_event_observers on: :update, with: :updated
  notify_event_observers on: :destroy, with: :destroyed do |model|
    { id: model.id, name: model.name }
  end

  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many_hosts
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  validates_lengths_from_database
  validates :name, :uniqueness => true, :presence => true

  default_scope -> { order('models.name') }

  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :info
  scoped_search :on => :vendor_class, :complete_value => :true
  scoped_search :on => :hardware_model, :complete_value => :true
end
