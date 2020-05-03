require 'ostruct'
require 'uri'

class Operatingsystem < ApplicationRecord
  audited
  include Authorizable
  include ValidateOsFamily
  include PxeLoaderSupport
  extend FriendlyId
  friendly_id :title

  validates_lengths_from_database
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  has_many_hosts
  has_many :hostgroups
  has_many :images, :dependent => :destroy
  has_and_belongs_to_many :media
  has_and_belongs_to_many :ptables, :join_table => :operatingsystems_ptables, :foreign_key => :operatingsystem_id, :association_foreign_key => :ptable_id
  has_and_belongs_to_many :architectures
  has_and_belongs_to_many :puppetclasses
  has_and_belongs_to_many :provisioning_templates, :join_table => :operatingsystems_provisioning_templates, :foreign_key => :operatingsystem_id, :association_foreign_key => :provisioning_template_id
  has_many :os_default_templates, :dependent => :destroy
  accepts_nested_attributes_for :os_default_templates, :allow_destroy => true,
    :reject_if => :reject_empty_provisioning_template

  validates :major, :numericality => {:greater_than_or_equal_to => 0}, :presence => { :message => N_("Operating System version is required") }
  has_many :os_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :operatingsystem
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "OsParameter"
  accepts_nested_attributes_for :os_parameters, :allow_destroy => true
  include ParameterValidators
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  attr_name :to_label
  validates :minor, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true, :allow_blank => true
  validates :name, :presence => true, :no_whitespace => true,
            :uniqueness => { :scope => [:major, :minor], :message => N_("Operating system version already exists")}
  validates :description, :uniqueness => true, :allow_blank => true
  validates :password_hash, :inclusion => { :in => PasswordCrypt::ALGORITHMS }
  validates :release_name, :presence => true, :if => Proc.new { |os| os.family == 'Debian' }
  before_validation :downcase_release_name, :set_title, :stringify_major_and_minor
  validates :title, :uniqueness => true, :presence => true

  before_validation :set_family

  default_scope -> { order(:title) }

  scoped_search :on => :name,        :complete_value => :true
  scoped_search :on => :major,       :complete_value => :true
  scoped_search :on => :minor,       :complete_value => :true
  scoped_search :on => :description, :complete_value => :true
  scoped_search :on => :type,        :complete_value => :true, :rename => "family"
  scoped_search :on => :title,       :complete_value => :true

  scoped_search :relation => :architectures,    :on => :name,  :complete_value => :true, :rename => "architecture", :only_explicit => true
  scoped_search :relation => :media,            :on => :name,  :complete_value => :true, :rename => "medium", :only_explicit => true
  scoped_search :relation => :provisioning_templates, :on => :name, :complete_value => :true, :rename => "template", :only_explicit => true
  scoped_search :relation => :os_parameters, :on => :value, :on_key => :name, :complete_value => true, :rename => :params, :only_explicit => true

  FAMILIES = { 'Debian'    => %r{Debian|Ubuntu}i,
               'Redhat'    => %r{RedHat|Centos|Fedora|Scientific|SLC|OracleLinux}i,
               'Suse'      => %r{OpenSuSE|SLES|SLED}i,
               'Windows'   => %r{Windows}i,
               'Altlinux'  => %r{Altlinux}i,
               'Archlinux' => %r{Archlinux}i,
               'Coreos'    => %r{CoreOS}i,
               'Rancheros' => %r{RancherOS}i,
               'Gentoo'    => %r{Gentoo}i,
               'Solaris'   => %r{Solaris}i,
               'Freebsd'   => %r{FreeBSD}i,
               'AIX'       => %r{AIX}i,
               'Junos'     => %r{Junos}i,
               'VRP'       => %r{VRP}i,
               'NXOS'      => %r{NX-OS}i,
               'Xenserver' => %r{XenServer}i }

  graphql_type '::Types::Operatingsystem'

  class Jail < Safemode::Jail
    allow :name, :media_url, :major, :minor, :family, :to_s, :==, :release, :release_name, :kernel, :initrd, :pxe_type, :boot_files_uri, :password_hash, :mediumpath
  end

  def self.title_name
    "title".freeze
  end

  def additional_media(medium_provider)
    medium_provider.additional_media.map(&:with_indifferent_access)
  end

  def self.inherited(child)
    child.instance_eval do
      # Ensure all subclasses behave in the same way as the parent, and remain
      # identified as Operatingsystems instead of subclasses in UI paths etc.
      #
      # rubocop:disable Rails/Delegate
      def model_name
        superclass.model_name
      end
      # rubocop:enable Rails/Delegate
    end
    super
  end

  # As Rails loads an object it casts it to the class in the 'type' field. If we ensure that the type and
  # family are the same thing then rails converts the record to a Debian or a solaris object as required.
  # Manually managing the 'type' field allows us to control the inheritance chain and the available methods
  def family
    self[:type]
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

  # The OS is usually represented as the concatenation of the OS and the revision
  def to_label
    return description if description.present?
    fullname
  end

  # to_label setter updates description and does not try to parse and update major, minor attributes
  def to_label=(str)
    self.description = str
  end

  def to_param
    Parameterizable.parameterize("#{id}-#{title}")
  end

  def release
    "#{major}#{('.' + minor.to_s) if minor.present?}"
  end

  def fullname
    "#{name} #{release}"
  end

  def to_s
    fullname
  end

  def self.find_by_to_label(str)
    os = self.find_by_description(str.to_s)
    return os if os
    a = str.split(" ")
    b = a[1].split('.') if a[1]
    cond = {:name => a[0]}
    cond[:major] = b[0] if b && b[0]
    cond[:minor] = b[1] if b && b[1]
    self.find_by(cond)
  end

  # Implemented only in the OSs subclasses where it makes sense
  def available_loaders
    ["None", "PXELinux BIOS"]
  end

  # The DHCP record type to use, can be overriden by OSs subclasses
  def dhcp_record_type
    Net::DHCP::Record
  end

  # sets the prefix for the tfp files based on medium unique identifier
  def pxe_prefix(medium_provider)
    unless medium_provider.is_a? MediumProviders::Provider
      raise Foreman::Exception.new(N_('Please provide a medium provider. It can be found as @medium_provider in templates, or Foreman::Plugin.medium_providers.find_provider(host)'))
    end
    "boot/#{medium_provider.unique_id}"
  end

  def pxe_files(medium_provider)
    unless medium_provider.is_a? MediumProviders::Provider
      raise Foreman::Exception.new(N_('Please provide a medium provider. It can be found as @medium_provider in templates, or Foreman::Plugin.medium_providers.find_provider(host)'))
    end
    boot_files_uri(medium_provider).collect do |img|
      { pxe_prefix(medium_provider).to_sym => img.to_s}
    end
  end

  def pxedir(medium_provider = nil)
    ""
  end

  def kernel(medium_provider)
    bootfile(medium_provider, :kernel)
  end

  def initrd(medium_provider)
    bootfile(medium_provider, :initrd)
  end

  def bootfile(medium_provider, type)
    unless medium_provider.is_a? MediumProviders::Provider
      raise Foreman::Exception.new(N_('Please provide a medium provider. It can be found as @medium_provider in templates, or Foreman::Plugin.medium_providers.find_provider(host)'))
    end
    pxe_prefix(medium_provider) + "-" + self.family.constantize::PXEFILES[type.to_sym]
  end

  # Does this OS family support a build variant that is constructed from a prebuilt archive
  def supports_image
    false
  end

  # Compatible kinds for this OS sorted by preferrence
  def template_kinds
    ['PXELinux', 'PXEGrub2', 'PXEGrub', 'iPXE']
  end

  # iPXE templates should not get transfered to tftp
  def template_kinds_for_tftp
    template_kinds.select { |kind| kind != 'iPXE' }
  end

  def boot_filename(host = nil)
    return default_boot_filename if host.nil? || host.pxe_loader.nil?
    return host.foreman_url('iPXE') if host.pxe_loader == 'iPXE Embedded'
    architecture = host.arch.nil? ? '' : host.arch.bootfilename_efi
    if host.subnet&.httpboot?
      if host.pxe_loader =~ /UEFI HTTPS/
        port = host.subnet.httpboot.setting(:HTTPBoot, 'https_port') || raise(::Foreman::Exception.new(N_("HTTPS boot requires proxy with httpboot feature and https_port exposed setting")))
      else
        port = host.subnet.httpboot.setting(:HTTPBoot, 'http_port') || raise(::Foreman::Exception.new(N_("HTTP boot requires proxy with httpboot feature and http_port exposed setting")))
      end
      hostname = URI.parse(host.subnet.httpboot.url).hostname
      self.class.all_loaders_map(architecture, "#{hostname}:#{port}")[host.pxe_loader]
    else
      raise(::Foreman::Exception.new(N_("HTTP UEFI boot requires proxy with httpboot feature"))) if host.pxe_loader =~ /UEFI HTTP/
      self.class.all_loaders_map(architecture)[host.pxe_loader]
    end
  end

  # Does this OS family use release_name in its naming scheme
  def use_release_name?
    return false unless family
    return self.becomes(family.constantize).use_release_name? unless self.class == family.constantize
    false
  end

  def image_extension
    raise ::Foreman::Exception.new(N_("Attempting to construct an operating system image filename but %s cannot be built from an image"), family)
  end

  # If this OS family requires access to its media via NFS
  def self.require_nfs_access_to_medium
    false
  end

  # Pretty method for displaying the Family name
  def display_family
    "Unknown"
  end

  def shorten_description(description)
    # This method should be overridden in the OS subclass
    # to handle shortening the specific formats of lsbdistdescription
    # returned by Facter on that OS
    description
  end

  def self.deduce_family(name)
    families.find do |f|
      name =~ FAMILIES[f]
    end
  end

  def deduce_family
    self.family || self.class.deduce_family(name)
  end

  def boot_files_uri(medium_provider, &block)
    boot_file_sources(medium_provider, &block).values
  end

  def url_for_boot(medium_provider, file, &block)
    boot_file_sources(medium_provider, &block)[file]
  end

  def boot_file_sources(medium_provider, &block)
    @boot_file_sources ||= self.family.constantize::PXEFILES.transform_values do |img|
      "#{medium_provider.medium_uri(pxedir(medium_provider), &block)}/#{img}"
    end
  end

  def pxe_kernel_options(params)
    options = []
    options << params['kernelcmd'] if params['kernelcmd']
    options
  end

  def mediumpath(medium_provider)
    medium_provider.medium_uri.to_s
  end

  private

  def set_family
    self.family ||= self.deduce_family
  end

  def set_title
    self.title = to_label.to_s[0..254]
  end

  def stringify_major_and_minor
    # Cast major and minor to strings. see db/schema.rb around lines 560-562 (Or https://github.com/theforeman/foreman/blob/develop/db/migrate/20090720134126_create_operatingsystems.rb#L4).
    # Need to ensure type when using major and minor as scopes for name uniqueness.
    self.major = major.to_s
    self.minor = minor.to_s
  end

  def downcase_release_name
    self.release_name = release_name.downcase if release_name.present?
  end

  def reject_empty_provisioning_template(attributes)
    template_exists = attributes[:id].present?
    provisioning_template_id_empty = attributes[:provisioning_template_id].blank?
    attributes[:_destroy] = 1 if template_exists && provisioning_template_id_empty
    (!template_exists && provisioning_template_id_empty)
  end
end
