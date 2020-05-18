class Model < ApplicationRecord
  audited
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include ::Foreman::ObservableModel

  set_hook :model_created, on: :create
  set_hook :model_updated, on: :update
  set_hook :model_destroyed, on: :destroy do |model|
    { id: model.id, name: model.name }
  end

  before_destroy EnsureNotUsedBy.new(:hosts)
  has_many_hosts

  validates_lengths_from_database
  validates :name, :uniqueness => true, :presence => true

  default_scope -> { order('models.name') }

  scoped_search :on => :name, :complete_value => :true, :default_order => true
  scoped_search :on => :info
  scoped_search :on => :vendor_class, :complete_value => :true
  scoped_search :on => :hardware_model, :complete_value => :true
end
