require 'ostruct'
require 'uri'

class Operatingsystem < ActiveRecord::Base
  include Authorizable
  include ValidateOsFamily
  extend FriendlyId
  friendly_id :title

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :media
  has_and_belongs_to_many :ptables
  has_and_belongs_to_many :architectures
  has_and_belongs_to_many :puppetclasses
  has_and_belongs_to_many :config_templates
  has_many :os_default_templates, :dependent => :destroy
  accepts_nested_attributes_for :os_default_templates, :allow_destroy => true,
    :reject_if => :reject_empty_config_template

  validates :major, :numericality => {:greater_than_or_equal_to => 0}, :presence => { :message => N_("Operating System version is required") }
  has_many :os_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :operatingsystem
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "OsParameter"
  accepts_nested_attributes_for :os_parameters, :allow_destroy => true
  include ParameterValidators
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"
  attr_name :to_label
  validates :minor, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true, :allow_blank => true
  validates :name, :presence => true, :format => {:with => /\A(\S+)\Z/, :message => N_("can't contain white spaces.")}
  validates :description, :uniqueness => true, :allow_blank => true
  validates :password_hash, :inclusion => { :in => PasswordCrypt::ALGORITHMS }
  before_validation :downcase_release_name, :set_title
  validates :title, :uniqueness => true, :presence => true

  before_save :set_family

  audited :allow_mass_assignment => true
  default_scope lambda { order('operatingsystems.name') }

  scoped_search :on => :name,        :complete_value => :true
  scoped_search :on => :major,       :complete_value => :true
  scoped_search :on => :minor,       :complete_value => :true
  scoped_search :on => :description, :complete_value => :true
  scoped_search :on => :type,        :complete_value => :true, :rename => "family"
  scoped_search :on => :title,       :complete_value => :true
  scoped_search :on => :hosts_count
  scoped_search :on => :hostgroups_count

  scoped_search :in => :architectures,    :on => :name,  :complete_value => :true, :rename => "architecture", :only_explicit => true
  scoped_search :in => :media,            :on => :name,  :complete_value => :true, :rename => "medium", :only_explicit => true
  scoped_search :in => :config_templates, :on => :name,  :complete_value => :true, :rename => "template", :only_explicit => true
  scoped_search :in => :os_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :rename => :params, :only_explicit => true

  FAMILIES = { 'Debian'    => %r{Debian|Ubuntu}i,
               'Redhat'    => %r{RedHat|Centos|Fedora|Scientific|SLC|OracleLinux}i,
               'Suse'      => %r{OpenSuSE|SLES|SLED}i,
               'Windows'   => %r{Windows}i,
               'Altlinux'  => %r{Altlinux}i,
               'Archlinux' => %r{Archlinux}i,
               'Gentoo'    => %r{Gentoo}i,
               'Solaris'   => %r{Solaris}i,
               'Freebsd'   => %r{FreeBSD}i,
               'AIX'       => %r{AIX}i,
               'Junos'     => %r{Junos}i }

  class Jail < Safemode::Jail
    allow :name, :media_url, :major, :minor, :family, :to_s, :repos, :==, :release_name, :kernel, :initrd, :pxe_type, :medium_uri
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
  validate_inclusion_in_families :type

  def self.families_as_collection
    families.map do |f|
      OpenStruct.new(:name => f.constantize.new.display_family, :value => f)
    end
  end

  # Operating system family can override this method to provide an array of
  # hashes, each describing a repository. For example, to describe a yum repo,
  # the following structure can be returned by the method:
  # [{ :baseurl => "https://dl.thesource.com/get/it/here",
  #    :name => "awesome",
  #    :description => "awesome product repo"",
  #    :enabled => 1,
  #    :gpgcheck => 1
  #  }]
  def repos(host)
    []
  end

  def medium_uri(host, url = nil)
    url ||= host.medium.path
    medium_vars_to_uri(url, host.architecture.name, host.os)
  end

  def medium_vars_to_uri(url, arch, os)
    URI.parse(interpolate_medium_vars(url, arch, os)).normalize
  end

  def interpolate_medium_vars(path, arch, os)
    return "" if path.empty?

    path.gsub('$arch',  arch).
         gsub('$major',  os.major).
         gsub('$minor',  os.minor).
         gsub('$version', [os.major, os.minor ].compact.join('.')).
         gsub('$release', os.release_name ? os.release_name : "" )
  end

  # The OS is usually represented as the concatenation of the OS and the revision
  def to_label
    return description if description.present?
    fullname
  end

  # to_label setter updates description and does not try to parse and update major, minor attributes
  def to_label=(str)
    self.description = str
  end

  def release
    "#{major}#{('.' + minor.to_s) unless minor.blank?}"
  end

  def fullname
    "#{name} #{release}"
  end

  def to_s
    fullname
  end

  def self.find_by_to_label(str)
    os = self.find_by_description(str)
    return os if os
    a = str.split(" ")
    b = a[1].split('.') if a[1]
    cond = {:name => a[0]}
    cond.merge!(:major => b[0]) if b && b[0]
    cond.merge!(:minor => b[1]) if b && b[1]
    self.where(cond).first
  end

  # sets the prefix for the tfp files based on the os / arch combination
  def pxe_prefix(arch)
    "boot/#{to_s}-#{arch}".gsub(" ","-")
  end

  def pxe_files(medium, arch, host = nil)
    boot_files_uri(medium, arch, host).collect do |img|
      { pxe_prefix(arch).to_sym => img.to_s}
    end
  end

  def kernel(arch)
    bootfile(arch,:kernel)
  end

  def initrd(arch)
    bootfile(arch,:initrd)
  end

  def bootfile(arch, type)
    pxe_prefix(arch) + "-" + eval("#{self.family}::PXEFILES[:#{type}]")
  end

  # Does this OS family support a build variant that is constructed from a prebuilt archive
  def supports_image
    false
  end

  # override in sub operatingsystem classes as required.
  def pxe_variant
    "syslinux"
  end

  # The kind of PXE configuration template used. PXELinux and PXEGrub are currently supported
  def template_kind
    "PXELinux"
  end

  #handle things like gpxelinux/ gpxe / pxelinux here
  def boot_filename(host = nil)
    "pxelinux.0"
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    false
  end

  def image_extension
    raise ::Foreman::Exception.new(N_("Attempting to construct an operating system image filename but %s cannot be built from an image"), family)
  end

  # If this OS family requires access to its media via NFS
  def require_nfs_access_to_medium
    false
  end

  # Pretty method for displaying the Family name
  def display_family
    "Unknown"
  end

  def self.shorten_description(description)
    # This method should be overridden in the OS subclass
    # to handle shortening the specific formats of lsbdistdescription
    # returned by Facter on that OS
    description
  end

  def deduce_family
    self.family || self.class.families.find do |f|
      name =~ FAMILIES[f]
    end
  end

  private
  def set_family
    self.family ||= self.deduce_family
  end

  def set_title
    self.title = to_label.to_s[0..254]
  end

  def downcase_release_name
    self.release_name.downcase! unless Foreman.in_rake? or release_name.nil? or release_name.empty?
  end

  def boot_files_uri(medium, architecture, host = nil)
    raise (_("invalid medium for %s") % to_s) unless media.include?(medium)
    raise (_("invalid architecture for %s") % to_s) unless architectures.include?(architecture)
    eval("#{self.family}::PXEFILES").values.collect do |img|
      medium_vars_to_uri("#{medium.path}/#{pxedir}/#{img}", architecture.name, self)
    end
  end

  def reject_empty_config_template(attributes)
    template_exists = attributes[:id].present?
    config_template_id_empty = attributes[:config_template_id].blank?
    attributes.merge!({:_destroy => 1}) if template_exists && config_template_id_empty
    (!template_exists && config_template_id_empty)
  end

end
