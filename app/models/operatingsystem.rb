require 'ostruct'
require 'uri'

class Operatingsystem < ActiveRecord::Base
  include Authorization
  has_many :hosts
  has_and_belongs_to_many :media
  has_and_belongs_to_many :ptables
  has_and_belongs_to_many :architectures
  has_and_belongs_to_many :puppetclasses
  has_and_belongs_to_many :config_templates
  has_many :os_default_templates, :dependent => :destroy
  accepts_nested_attributes_for :os_default_templates, :allow_destroy => true,
    :reject_if => lambda { |v| v[:template_kind_id].blank? }

  validates_presence_of :major, :message => "Operating System version is required"
  has_many :os_parameters, :dependent => :destroy, :foreign_key => :reference_id

  accepts_nested_attributes_for :os_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  validates_numericality_of :major
  validates_numericality_of :minor, :allow_nil => true, :allow_blank => true
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  before_validation :downcase_release_name
  #TODO: add validation for name and major uniqueness

  before_destroy Ensure_not_used_by.new(:hosts)
  before_save :deduce_family
  acts_as_audited
  default_scope :order => 'LOWER(operatingsystems.name)'

  FAMILIES = {'Debian'  => %r{Debian|Ubuntu}i,
              'Redhat'  => %r{RedHat|Centos|Fedora|Scientific}i,
              'Solaris' => %r{Solaris}i}


  class Jail < Safemode::Jail
    allow :name, :media_url, :major, :minor, :family, :to_s, :epel, :==, :release_name, :kernel, :initrd
  end

  # As Rails loads an object it casts it to the class in the 'type' field. If we ensure that the type and
  # family are the same thing then rails converts the record to a Debian or a solaris object as required.
  # Manually managing the 'type' field allows us to control the inheritance chain and the available methods
  def family
    read_attribute(:type)
  end

  def family=(value)
    self.type = value
  end

  def self.families
    FAMILIES.keys.sort
  end

  def self.families_as_collection
    families.map{|e| OpenStruct.new(:name => e, :value => e) }
  end

  def medium_uri host, url = nil
    url ||= host.medium.path
    medium_vars_to_uri(url, host.architecture.name, host.os)
  end

  def medium_vars_to_uri (url, arch, os)
    URI.parse(url.gsub('$arch',  arch).
              gsub('$major',  os.major).
              gsub('$minor',  os.minor).
              gsub('$version', [os.major, os.minor ].compact.join('.'))
             ).normalize
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

  # sets the prefix for the tfp files based on the os / arch combination
  def pxe_prefix(arch)
    "boot/#{to_s}-#{arch}".gsub(" ","-")
  end

  def pxe_files(medium, arch)
    boot_files_uri(medium, arch).collect do |img|
      { pxe_prefix(arch).to_sym => img.to_s}
    end
  end

  def as_json(options={})
    {:operatingsystem => {:name => to_s, :id => id, :media => media, :architectures => architectures, :ptables => ptables}}
  end

  def kernel arch
    bootfile(arch,:kernel)
  end

  def initrd arch
    bootfile(arch,:initrd)
  end

  private
  def deduce_family
    if self.family.blank?
      found = nil
      for f in self.class.families
        if name =~ FAMILIES[f]
          found = f
        end
      end
      self.family = found
    end
  end

  def downcase_release_name
    self.release_name.downcase! unless defined?(Rake) or release_name.nil? or release_name.empty?
  end

  def boot_files_uri(medium = nil , architecture = nil)
    "Abstract"
  end

  def bootfile arch, type
    pxe_prefix(arch) + "-" + eval("#{self.family}::PXEFILES[:#{type}]")
  end

end
