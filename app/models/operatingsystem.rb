require 'ostruct'
require 'uri'

class Operatingsystem < ActiveRecord::Base
  include Authorization

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
    :reject_if => lambda { |v| v[:config_template_id].blank? }

  validates_presence_of :major, :message => N_("Operating System version is required")
  has_many :os_parameters, :dependent => :destroy, :foreign_key => :reference_id
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "OsParameter"
  accepts_nested_attributes_for :os_parameters, :reject_if => lambda { |a| a[:value].blank? }, :allow_destroy => true
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"
  validates_numericality_of :major
  validates_numericality_of :minor, :allow_nil => true, :allow_blank => true
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => N_("can't be blank or contain white spaces.")
  before_validation :downcase_release_name
  #TODO: add validation for name and major uniqueness

  before_save :deduce_family
  audited
  default_scope :order => 'LOWER(operatingsystems.name)'

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :major, :complete_value => :true
  scoped_search :on => :minor, :complete_value => :true
  scoped_search :on => :type, :complete_value => :true, :rename => "family"

  scoped_search :in => :architectures,    :on => :name, :complete_value => :true, :rename => "architecture"
  scoped_search :in => :media,            :on => :name, :complete_value => :true, :rename => "medium"
  scoped_search :in => :config_templates, :on => :name, :complete_value => :true, :rename => "template"
  scoped_search :in => :os_parameters,    :on => :value, :on_key=> :name, :complete_value => true, :rename => :params

  FAMILIES = { 'Debian'  => %r{Debian|Ubuntu}i,
               'Redhat'  => %r{RedHat|Centos|Fedora|Scientific|SLC}i,
               'Suse'    => %r{OpenSuSE}i,
               'Windows' => %r{Windows}i,
               'Archlinux' => %r{Archlinux}i,
               'Solaris' => %r{Solaris}i }

  class Jail < Safemode::Jail
    allow :name, :media_url, :major, :minor, :family, :to_s, :epel, :==, :release_name, :kernel, :initrd, :pxe_type, :medium_uri
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
    URI.parse(interpolate_medium_vars(url, arch, os)).normalize
  end

  def interpolate_medium_vars path, arch, os
    return "" if path.empty?

    path.gsub('$arch',  arch).
         gsub('$major',  os.major).
         gsub('$minor',  os.minor).
         gsub('$version', [os.major, os.minor ].compact.join('.')).
         gsub('$release', os.release_name ? os.release_name : "" )
  end

  # The OS is usually represented as the concatenation of the OS and the revision
  def to_label
    "#{name} #{release}"
  end

  def release
    "#{major}#{('.' + minor) unless minor.empty?}"
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
    {:operatingsystem => {:name => to_s, :id => id, :media => media, :architectures => architectures, :ptables => ptables, :config_templates => config_templates}}
  end

  def kernel arch
    bootfile(arch,:kernel)
  end

  def initrd arch
    bootfile(arch,:initrd)
  end

  def bootfile arch, type
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
  def boot_filename host=nil
    "pxelinux.0"
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    false
  end

  def image_extension
    raise ::Foreman::Exception(N_("Attempting to construct an operating system image filename but %s cannot be built from an image"), family)
  end

  # If this OS family requires access to its media via NFS
  def require_nfs_access_to_medium
    false
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

  def boot_files_uri(medium, architecture)
    raise (_("invalid medium for %s") % to_s) unless media.include?(medium)
    raise (_("invalid architecture for %s") % to_s) unless architectures.include?(architecture)
    eval("#{self.family}::PXEFILES").values.collect do |img|
      medium_vars_to_uri("#{medium.path}/#{pxedir}/#{img}", architecture.name, self)
    end
  end

end
