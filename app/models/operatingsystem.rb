class Operatingsystem < ActiveRecord::Base
  has_many :hosts
  has_and_belongs_to_many :medias
  has_and_belongs_to_many :ptables
  has_and_belongs_to_many :architectures
  has_and_belongs_to_many :puppetclasses
  validates_presence_of :major, :message => "Operating System version is required"
  validates_presence_of :name
  validates_numericality_of :major
  validates_numericality_of :minor, :allow_nil => true, :allow_blank => true
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  before_validation :downcase_release_name
  #TODO: add validation for name and major uniqueness

  before_destroy Ensure_not_used_by.new(:hosts)
  acts_as_audited

  # Emulate multiple inheritance from a virtual Family class
  def after_initialize
    extend eval("Family::#{Family::FAMILIES[family_id]}") unless family_id.nil?
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

  def fullname
    to_label
  end

  private
  def downcase_release_name
    self.release_name.downcase! unless defined?(Rake) or release_name.nil? or release_name.empty?
  end

end
