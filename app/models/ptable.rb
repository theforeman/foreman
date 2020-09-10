# This models the partition tables for a disk layouts
# It supports both static partition maps and dynamic scripts that create partition tables on-the-fly
# A host object may contain a reference to one of these ptables or, alternatively, it may contain a
# modified version of one of these in textual form
class Ptable < Template
  audited
  has_many :audits, :as => :auditable, :class_name => Audited.audit_class.name

  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName
  include ValidateOsFamily
  include DirtyAssociations
  include TaxonomyCollisionFinder

  class << self
    # we have to override the base_class because polymorphic associations does not detect it correctly, more details at
    # http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_many#1010-Polymorphic-has-many-within-inherited-class-gotcha
    def base_class
      self
    end
  end
  self.table_name = 'templates'

  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  has_many_hosts
  has_many :hostgroups
  has_and_belongs_to_many :operatingsystems, :join_table => :operatingsystems_ptables, :association_foreign_key => :operatingsystem_id, :foreign_key => :ptable_id
  validates :layout, :presence => true
  validates :name, :uniqueness => true
  validates :os_family, :absence => true, :if => proc { |ptable| ptable.snippet }
  validate_inclusion_in_families :os_family

  # these can't be shared in parent class, scoped search can't handle STI properly
  # tested with scoped_search 3.2.0
  include Taxonomix
  include TemplateTax
  scoped_search :on => :name,    :complete_value => true, :default_order => true
  scoped_search :on => :locked,  :complete_value => {:true => true, :false => false}
  scoped_search :on => :snippet, :complete_value => {:true => true, :false => false}
  scoped_search :on => :template
  scoped_search :on => :vendor, :only_explicit => true, :complete_value => true
  scoped_search :on => :default, :only_explicit => true, :complete_value => {:true => true, :false => false}

  scoped_search :on => :template, :complete_value => false, :rename => 'layout'
  scoped_search :on => :os_family, :rename => 'family', :complete_value => :true

  alias_attribute :layout, :template

  attr_exportable :os_family, taxonomy_exportable

  dirty_has_many_associations :operatingsystems

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("#{Template.table_name}.name")
    end
  }

  apipie :class, desc: 'A class representing Partition Table object' do
    sections only: %w[all additional]
    prop_group :basic_model_props, ApplicationRecord, meta: { friendly_name: 'partition table', example: 'Kickstart default' }
  end
  class Jail < Safemode::Jail
    allow :id, :name
  end

  def self.template_includes
    super + [:operatingsystems]
  end

  def self.default_render_scope_class
    Foreman::Renderer::Scope::Partition
  end

  def self.preview_host_collection
    super.where(:managed => true)
  end

  def taxonomy_foreign_conditions
    { :ptable_id => id }
  end

  def self.acceptable_template_input_types
    [:fact, :variable, :puppet_parameter]
  end

  private

  def import_custom_data(options)
    super
    import_oses(options)
    import_os_family(options)
  end

  def import_os_family(options)
    if @importing_metadata.key?('oses') && associate_metadata_on_import?(options)
      family = @importing_metadata['oses'].map do |imported_os|
        Operatingsystem::FAMILIES.find { |key, regexp| imported_os =~ regexp }&.first
      end.compact.first
      self.os_family = family
    end
  end
end
