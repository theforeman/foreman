class Puppetclass < ApplicationRecord
  audited
  include Authorizable
  include ScopedSearchExtensions
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  has_many :environment_classes, :dependent => :destroy, :inverse_of => :puppetclass
  has_many :environments, -> { distinct }, :through => :environment_classes
  has_many :organizations, -> { distinct.reorder(nil) }, :through => :environments
  has_many :locations, -> { distinct.reorder(nil) }, :through => :environments

  has_and_belongs_to_many :operatingsystems
  has_many :hostgroup_classes
  has_many :hostgroups, :through => :hostgroup_classes, :dependent => :destroy
  has_many :host_classes
  has_many_hosts :through => :host_classes, :dependent => :destroy
  has_many :config_group_classes
  has_many :config_groups, :through => :config_group_classes, :dependent => :destroy
  # param classes
  has_many :class_params, -> { where('environment_classes.puppetclass_lookup_key_id is NOT NULL').distinct },
    :through => :environment_classes, :source => :puppetclass_lookup_key
  accepts_nested_attributes_for :class_params, :reject_if => ->(a) { a[:key].blank? }, :allow_destroy => true

  validates :name, :uniqueness => true, :presence => true, :no_whitespace => true

  alias_attribute :smart_class_parameters, :class_params
  alias_attribute :smart_class_parameter_ids, :class_param_ids

  default_scope -> { order('puppetclasses.name') }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :relation => :environments, :on => :name, :complete_value => :true, :rename => "environment"
  scoped_search :relation => :organizations, :on => :name, :complete_value => :true, :rename => "organization", :only_explicit => true
  scoped_search :relation => :locations, :on => :name, :complete_value => :true, :rename => "location", :only_explicit => true
  scoped_search :relation => :hostgroups, :on => :name, :complete_value => :true, :rename => "hostgroup", :only_explicit => true
  scoped_search :relation => :config_groups, :on => :name, :complete_value => :true, :rename => "config_group", :only_explicit => true
  scoped_search :relation => :hosts, :on => :name, :complete_value => :true, :rename => "host", :ext_method => :search_by_host, :only_explicit => true
  scoped_search :relation => :class_params, :on => :key, :complete_value => :true, :only_explicit => true

  scope :not_in_any_environment, -> { includes(:environment_classes).where(:environment_classes => {:environment_id => nil}) }

  # returns a hash containing modules and associated classes
  def self.classes2hash(classes)
    hash = {}
    classes.each do |klass|
      if (mod = klass.module_name)
        hash[mod] ||= []
        hash[mod] << klass
      else
        next
      end
    end
    hash
  end

  # For API v2 - eliminate node :puppetclass for each object. returns a hash containing modules and associated classes
  def self.classes2hash_v2(classes)
    hash = {}
    classes.each do |klass|
      if (mod = klass.module_name)
        hash[mod] ||= []
        hash[mod] << {:id => klass.id, :name => klass.name, :created_at => klass.created_at, :updated_at => klass.updated_at}
      end
    end
    hash
  end

  # returns module name (excluding of the class name)
  # if class separator does not exists (the "::" chars), then returns the whole class name
  def module_name
    (i = name.index("::")) ? name[0..i - 1] : name
  end

  # returns class name (excluding of the module name)
  def klass
    name.gsub(module_name + "::", "")
  end

  def all_hostgroups(with_descendants = true, unsorted = false)
    hgs = Hostgroup.authorized
                   .eager_load(:hostgroup_classes, :config_groups => [:config_group_classes])
                   .where("#{id} IN (hostgroup_classes.puppetclass_id, config_group_classes.puppetclass_id)")
                   .distinct
    hgs = hgs.reorder('') if unsorted
    hgs = hgs.flat_map(&:subtree).uniq if with_descendants
    hgs
  end

  def hosts_count
    Host::Managed.authorized
                 .reorder('')
                 .eager_load(:host_classes, :config_groups => [:config_group_classes])
                 .where("(? IN (host_classes.puppetclass_id, config_group_classes.puppetclass_id)) OR (hosts.hostgroup_id IN (?))", id, all_hostgroups(true, true).map(&:id))
                 .count
  end

  def self.search_by_host(key, operator, value)
    conditions = sanitize_sql_for_conditions(["hosts.name #{operator} ?", value_to_sql(operator, value)])
    direct     = Puppetclass.joins(:hosts).where(conditions).pluck('puppetclasses.id').uniq
    hostgroup  = Hostgroup.joins(:hosts).find_by(conditions)
    indirect   = hostgroup.blank? ? [] : HostgroupClass.where(:hostgroup_id => hostgroup.path_ids).distinct.pluck('puppetclass_id')
    return { :conditions => "1=0" } if direct.blank? && indirect.blank?

    puppet_classes = (direct + indirect).uniq
    { :conditions => "puppetclasses.id IN(#{puppet_classes.join(',')})" }
  end
end
