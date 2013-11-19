class SystemGroup < ActiveRecord::Base
  has_ancestry :orphan_strategy => :rootify
  include Authorization
  include Taxonomix
  include SystemCommon

  before_destroy EnsureNotUsedBy.new(:systems)
  has_many :system_group_classes, :dependent => :destroy
  has_many :puppetclasses, :through => :system_group_classes
  has_many :user_system_groups, :dependent => :destroy
  has_many :users, :through => :user_system_groups
  validates :name, :uniqueness => {:scope => :ancestry, :case_sensitive => false },
                   :format => { :with => /\A(\S+\s?)+\Z/, :message => N_("can't be blank or contain trailing white spaces.")}
  has_many :group_parameters, :dependent => :destroy, :foreign_key => :reference_id
  accepts_nested_attributes_for :group_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many_systems
  has_many :template_combinations, :dependent => :destroy
  has_many :config_templates, :through => :template_combinations
  before_save :remove_duplicated_nested_class
  before_save :set_label, :on => [:create, :update, :destroy]
  after_save :set_other_labels, :on => [:update, :destroy]

  alias_attribute :os, :operatingsystem
  audited :except => [:label], :allow_mass_assignment => true
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"
  # attribute used by *_names and *_name methods.  default is :name
  attr_name :label

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("system_groups.label")
    end
  }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :label, :complete_value => :true
  scoped_search :in => :group_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :only_explicit => true, :rename => :params
  scoped_search :in => :systems, :on => :name, :complete_value => :true, :rename => "system"
  scoped_search :in => :puppetclasses, :on => :name, :complete_value => true, :rename => :class, :operators => ['= ', '~ ']
  scoped_search :in => :environment, :on => :name, :complete_value => :true, :rename => :environment
  if SETTINGS[:unattended]
    scoped_search :in => :architecture, :on => :name, :complete_value => :true, :rename => :architecture
    scoped_search :in => :operatingsystem, :on => :name, :complete_value => true, :rename => :os
    scoped_search :in => :medium,            :on => :name, :complete_value => :true, :rename => "medium"
    scoped_search :in => :config_templates, :on => :name, :complete_value => :true, :rename => "template"
  end

  # returns reports for systems in the User's filter set
  scope :my_groups, lambda {
    user = User.current
    unless user.admin?
      conditions = sanitize_sql_for_conditions([" (system_groups.id in (?))", user.system_group_ids])
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    where(conditions)
  }

  class Jail < Safemode::Jail
    allow :name, :diskLayout, :puppetmaster, :operatingsystem, :architecture,
      :environment, :ptable, :url_for_boot, :params, :puppetproxy
  end

  #TODO: add a method that returns the valid os for a system_group

  def all_puppetclasses
    classes
  end

  def to_label
    return label if label
    get_label
  end

  def to_param
    "#{id}-#{to_label.parameterize}"
  end

  def system_group
    self
  end

  def diskLayout
    ptable.layout.gsub("\r","")
  end

  def classes
    Puppetclass.joins(:system_groups).where(:system_groups => {:id => path_ids})
  end

  def puppetclass_ids
    classes.reorder('').pluck('puppetclasses.id')
  end

  def inherited_lookup_value key
    ancestors.reverse.each do |hg|
      if(v = LookupValue.where(:lookup_key_id => key.id, :id => hg.lookup_values).first)
        return v.value, hg.to_label
      end
    end if key.path_elements.flatten.include?("system_group") && Setting["system_group_matchers_inheritance"]
    return key.default_value, _("Default value")
  end

  # returns self and parent parameters as a hash
  def parameters include_source = false
    hash = {}
    ids = ancestor_ids
    ids << id unless new_record? or self.frozen?
    # need to pull out the system_groups to ensure they are sorted first,
    # otherwise we might be overwriting the hash in the wrong order.
    groups = ids.size == 1 ? [self] : SystemGroup.includes(:group_parameters).sort_by_ancestry(SystemGroup.find(ids))
    groups.each do |hg|
      hg.group_parameters.each {|p| hash[p.name] = include_source ? {:value => p.value, :source => :system_group} : p.value }
    end
    hash
  end

  def params
    parameters = {}
    # read common parameters
    CommonParameter.all.each {|p| parameters.update Hash[p.name => p.value] }
    # read OS parameters
    operatingsystem.os_parameters.each {|p| parameters.update Hash[p.name => p.value] } unless operatingsystem.nil?
    # read group parameters only if a system belongs to a group
    parameters.update self.parameters unless system_group.nil?
    parameters
  end

  # no need to store anything in the db if the password is our default
  def root_pass
    read_attribute(:root_pass) || nested_root_pw || Setting[:root_pass]
  end

  def get_label
    return name if ancestry.empty?
    ancestors.map{|a| a.name + "/"}.join + name
  end

  private

  def lookup_value_match
    "system_group=#{to_label}"
  end

  def set_label
    self.label = get_label if (name_changed? || ancestry_changed? || label.blank?)
  end

  def set_other_labels
    if name_changed? || ancestry_changed?
      SystemGroup.where("ancestry IS NOT NULL").each do |system_group|
        if system_group.path_ids.include?(self.id)
          system_group.update_attributes(:label => system_group.get_label)
        end
      end
    end
  end

  def nested_root_pw
    SystemGroup.sort_by_ancestry(ancestors).reverse.each do |a|
      return a.root_pass unless a.root_pass.blank?
    end if ancestry.present?
    nil
  end

  def remove_duplicated_nested_class
    self.puppetclasses -= ancestors.map(&:puppetclasses).flatten
  end

end
