class FactName < ApplicationRecord
  include Parameterizable::ByIdName

  SEPARATOR = '::'

  validates_lengths_from_database
  has_many :fact_values, :dependent => :destroy
  has_many_hosts :through => :fact_values

  scope :no_timestamp_fact, -> { where("fact_names.name <> ?", :_timestamp) }
  scope :timestamp_facts, -> { where(:name => :_timestamp) }
  scope :composes, -> { where(:compose => true) }
  scope :leaves, -> { where(:compose => false) }

  scope :with_parent_id, lambda { |find_ids|
    conds, binds = [], []
    [find_ids].flatten.each do |find_id|
      conds.push "(fact_names.ancestry LIKE '%/?' OR fact_names.ancestry = '?')"
      binds.push find_id, find_id
    end
    where(conds.join(' OR '), *binds)
  }

  default_scope -> { order('fact_names.name') }

  validates :name, :uniqueness => { :scope => :type }

  before_save :set_name, :if => proc { |fact| fact.short_name.blank? }

  has_ancestry

  def set_name
    self.short_name = name.split(SEPARATOR).last
  end

  # To be overridden in subclasses to specify what is the origin of this
  # fact, normally a configuration management system, e.g: 'Puppet', 'Ansible'...
  def origin
    'N/A'
  end

  # Relative path within app/assets/images to the 16x16 icon in PNG format.
  # Stock (stub) icons can be used, e.g. "icons16x16/stub/green-h.png".
  def icon_path
    "icons16x16/stub/black-x.png"
  end
end
