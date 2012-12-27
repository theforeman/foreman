class Taxonomy < ActiveRecord::Base
  audited
  has_associated_audits

  serialize :ignore_types, Array
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :type

  belongs_to :user

  has_many :taxable_taxonomies, :dependent => :destroy
  has_many :users, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'User'
  has_many :smart_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'SmartProxy'
  has_many :compute_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ComputeResource'
  has_many :media, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Medium'
  has_many :config_templates, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ConfigTemplate'
  has_many :domains, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Domain'
  has_many :hostgroups, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Hostgroup'
  has_many :environments, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Environment'
  has_many :subnets, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Subnet'

  scoped_search :on => :name, :complete_value => true

  validate :check_for_orphans

  def to_param
    "#{id.to_s.parameterize}"
  end

  def to_label
    name =~ /[A-Z]/ ? name : name.capitalize
  end

  def self.locations_enabled
    SETTINGS[:locations_enabled]
  end

  def self.organizations_enabled
    SETTINGS[:organizations_enabled]
  end

  def self.no_taxonomy_scope
    as_taxonomy nil, nil do
      yield if block_given?
    end
  end

  def self.as_taxonomy org, location
    Organization.as_org org do
      Location.as_location location do
        yield if block_given?
      end
    end
  end

  def ignore?(taxable_type)
    if ignore_types.empty?
      false
    else
      ignore_types.include?(taxable_type.classify)
    end
  end

  def used_ids
    @used_ids ||= TaxHost.new(self).used_ids
  end

  def selected_ids
    @selected_ids ||= TaxHost.new(self).selected_ids
  end

  def used_and_selected_ids
    @used_and_selected_ids ||= TaxHost.new(self).used_and_selected_ids
  end

  def need_to_be_selected_ids
    @need_to_be_selected_ids ||= TaxHost.new(self).need_to_be_selected_ids
  end

  def import_missing_ids
    TaxHost.new(self).import_missing_ids
    return "Imported taxable_taxonomy settings for #{name}"
  end

  def mismatches
    @mismatches ||= TaxHost.new(self).mismatches
  end

  def self.all_import_missing_ids
    Taxonomy.all.each do |taxonomy|
      TaxHost.new(taxonomy).import_missing_ids
    end
    return "Imported all taxable_taxonomy settings"
  end

  def self.all_mismatcheds
    return @all_mismatcheds if @all_mismatcheds
    all_mismatcheds = Array.new
    Taxonomy.all.each do |taxonomy|
      all_mismatcheds << TaxHost.new(taxonomy).mismatches
    end
    @all_mismatcheds = all_mismatcheds
  end

  def check_for_orphans
    @need_to_be_selected_ids = nil
    a = TaxHost.new(self).need_to_be_selected_ids
    found_orphan = false
    error_msg = "The following must be selected since they belong to hosts:\n\n"
    a.each do |key, array_values|
      unless array_values.length == 0
        class_name = key.to_s[0..-5].classify
        klass = class_name.constantize
        array_values.each do |id|
          row = klass.find_by_id(id)
          error_msg += "#{row.to_s} (#{class_name}) \n"
          found_orphan = true
        end
        errors.add(class_name.tableize, "You cannot remove #{class_name.tableize.humanize.downcase} that are used by hosts.")
      end
    end
    errors.add(:base, error_msg, "asdfasdf") if found_orphan
  end

end
