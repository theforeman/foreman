class Operatingsystem < ActiveRecord::Base
  has_many :hosts
  has_many :medias
  has_and_belongs_to_many :ptables
  has_and_belongs_to_many :architectures
  has_and_belongs_to_many :puppetclasses
  validates_presence_of :major, :message => "Operating System version is required"
  validates_presence_of :name
  validates_numericality_of :major
  validates_numericality_of :minor, :allow_nil => true
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  #TODO: add validation for name and major uniqueness

  before_destroy Ensure_not_used_by.new(:hosts)
  acts_as_audited

  # Emulate multiple inheritance from a virtual Family class
  def after_initialize
    extend eval("Family::#{Family::FAMILIES[family_id]}") if family_id
  end

  def family
  end

  def family= value
    if index = Family::FAMILIES.index(value.to_sym)
      update_attribute(:family_id, index)
    else
      raise RuntimeError, "Unable to find family [#{value}]"
    end
  end

  # The OS is usually represented as the catenation of the OS and the revision. E.G. "Solaris 10"
  def to_label
    "#{name} #{major}#{('.' + minor) unless minor.empty?}"
  end

  def to_s
    to_label
  end

  def to_version
    "#{major}#{('-' + minor) unless minor.empty?}"
  end

  def fullname
    "#{name}_#{to_version}"
  end

end
