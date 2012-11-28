class Taxonomy < ActiveRecord::Base
  audited
  has_associated_audits

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :type

  belongs_to :user

  has_many :taxable_taxonomies, :dependent => :destroy
  has_many :users, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'User'
  has_many :smart_proxies, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'SmartProxy'
  has_many :compute_resources, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'ComputeResource'
  has_many :media, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Medium'
  has_many :domains, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Domain'
  has_many :hostgroups, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Hostgroup'
  has_many :environments, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Environment'
  has_many :subnets, :through => :taxable_taxonomies, :source => :taxable, :source_type => 'Subnet'

  scoped_search :on => :name, :complete_value => true

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

end
