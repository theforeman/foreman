# This models the partition tables for a disk layouts
# It supports both static partition maps and dynamic scripts that create partition tables on-the-fly
# A host object may contain a reference to one of these ptables or, alternatively, it may contain a
# modified version of one of these in textual form
class Ptable < Template
  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include ValidateOsFamily

  audited :allow_mass_assignment => true
  has_many :audits, :as => :auditable, :class_name => Audited.audit_class.name

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  has_many_hosts
  has_many :hostgroups
  has_and_belongs_to_many :operatingsystems, :join_table => :operatingsystems_ptables, :association_foreign_key => :operatingsystem_id, :foreign_key => :ptable_id
  validates :layout, :presence => true
  validates :name, :uniqueness => true
  validate_inclusion_in_families :os_family
  include AccessibleAttributes

  # these can't be shared in parent class, scoped search can't handle STI properly
  # tested with scoped_search 3.2.0
  include Taxonomix
  scoped_search :on => :name,    :complete_value => true, :default_order => true
  scoped_search :on => :locked,  :complete_value => {:true => true, :false => false}
  scoped_search :on => :snippet, :complete_value => {:true => true, :false => false}
  scoped_search :on => :template

  scoped_search :on => :template, :complete_value => false, :rename => 'layout'
  scoped_search :on => :os_family, :rename => 'family', :complete_value => :true

  alias_attribute :layout, :template
  attr_accessible :layout

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("#{Template.table_name}.name")
    end
  }

  # we have to override the base_class because polymorphic associations does not detect it correctly, more details at
  # http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_many#1010-Polymorphic-has-many-within-inherited-class-gotcha
  def self.base_class
    self
  end

  def self.template_includes
    super + [:operatingsystems]
  end

  def preview_host_collection
    super.where(:managed => true)
  end
end
