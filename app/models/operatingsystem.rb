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
  has_and_belongs_to_many :provisioning_templates, :join_table => :operatingsystems_provisioning_templates, :foreign_key => :operatingsystem_id, :association_foreign_key => :provisioning_template_id
  has_many :os_default_templates, :dependent => :destroy
  accepts_nested_attributes_for :os_default_templates, :allow_destroy => true,
    :reject_if => :reject_empty_provisioning_template

  validates :major, numericality: true, presence: { message: N_("Operating System version is required") }
  validates :minor, format: { with: /\A\d+(\.\d+)*\z/, message: "Operating System minor version must be in N or N.N format" }, allow_blank: true
  has_many :os_parameters, :dependent => :destroy, :foreign_key => :reference_id, :inverse_of => :operatingsystem
  has_many :parameters, :dependent => :destroy, :foreign_key => :reference_id, :class_name => "OsParameter"
  accepts_nested_attributes_for :os_parameters, :allow_destroy => true
  include ParameterValidators
  include ScopedSearchExtensions
  include ParameterSearch

  attr_name :to_label
  validates :name, :presence => true, :no_whitespace => true,
            :uniqueness => { :scope => [:major, :minor], :message => N_("Operating system version already exists")}
  validates :description, :uniqueness => true, :allow_blank => true
  validates :password_hash, :inclusion => { :in => PasswordCrypt::ALGORITHMS }
  validates :release_name, :presence => true, :if => proc { |os| os.family == 'Debian' }
  before_validation :downcase_release_name, :set_title, :stringify_major_and_minor
  validates :title, :uniqueness => true, :presence => true

  before_validation :set_family

  after_create :assign_init_config_template

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

  FAMILIES = { 'Debian'    => %r{Debian|Ubuntu}i,
               'Redhat'    => %r{RedHat|Centos|Fedora|Scientific|SLC|OracleLinux|AlmaLinux|Rocky|Amazon}i,
               'Suse'      => %r{OpenSuSE|SLES|SLED}i,
               'Windows'   => %r{Windows}i,
               'Altlinux'  => %r{Altlinux}i,
               'Archlinux' => %r{Archlinux}i,
               'Coreos'    => %r{CoreOS|Flatcar}i,
               'Fcos'      => %r{FCOS|FedoraCoreOS|FedoraCOS}i,
               'Rhcos'     => %r{RHCOS|RedHatCoreOS|RedHatCOS}i,
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

  apipie :class, desc: "A class representing #{model_name.human} object" do
    sections only: %w[all additional]
    prop_group :basic_model_props, ApplicationRecord, meta: { friendly_name: 'operating system consisting', example: 'RedHat, Fedora, Debian' }
    property :major, String, desc: 'Major version of the operating system'
    property :minor, String, desc: 'Minor version of the operating system'
    property :family, String, desc: 'Family of the operating system, e.g. Redhat'
    property :to_s, String, desc: 'Returns full name of the operating system, e.g. CentOS 7.0'
    property :release, String, desc: 'Full release version, e.g. 7.0'
    property :release_name, String, desc: 'Release name of the operating system, e.g. stretch'
    property :pxe_type, String, desc: 'PXE type of the operating system, e.g. kickstart'
    property :password_hash, String, desc: 'Encrypted hash of the operating system password'
  end
  class Jail < ApplicationRecord::Jail
    allow :id, :name, :major, :minor, :family, :to_s, :==, :release, :release_name, :kernel, :initrd, :pxe_type, :boot_files_uri, :password_hash, :mediumpath
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
    os = find_by_description(str.to_s)
    return os if os
    a = str.split(" ")
    b = a[1].split('.') if a[1]
    cond = {:name => a[0]}
    cond[:major] = b[0] if b && b[0]
    cond[:minor] = b[1] if b && b[1]
    find_by(cond)
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
      raise Foreman::Exception.new(N_('Please provide a medium provider. It can be found as @medium_provider in templates, or Foreman::Plugin.medium_providers_registry.find_provider(host)'))
    end
    "boot/#{medium_provider.unique_id}"
  end

  def pxe_files(medium_provider)
    unless medium_provider.is_a? MediumProviders::Provider
      raise Foreman::Exception.new(N_('Please provide a medium provider. It can be found as @medium_provider in templates, or Foreman::Plugin.medium_providers_registry.find_provider(host)'))
    end
    boot_files_uri(medium_provider).collect do |img|
      { pxe_prefix(medium_provider).to_sym => img.to_s}
    end
  end

  def pxedir(medium_provider = nil)
    ""
  end

  apipie :method, 'Returns path to the kernel to be installed with prefix based on given medium provider' do
    required :medium_provider, 'MediumProviders::Provider', 'Medium provider responsible to provide location of installation medium for a given entity (host or host group)'
    returns String, 'Path to the kernel to be installed'
  end
  def kernel(medium_provider)
    bootfile(medium_provider, :kernel)
  end

  apipie :method, 'Returns path to the initial RAM disk with prefix based on given medium provider' do
    required :medium_provider, 'MediumProviders::Provider', 'Medium provider responsible to provide location of installation medium for a given entity (host or host group)'
    returns String, 'Path to the initial RAM disk'
  end
  def initrd(medium_provider)
    bootfile(medium_provider, :initrd)
  end

  def bootfile(medium_provider, type)
    unless medium_provider.is_a? MediumProviders::Provider
      raise Foreman::Exception.new(N_('Please provide a medium provider. It can be found as @medium_provider in templates, or Foreman::Plugin.medium_providers_registry.find_provider(host)'))
    end
    pxe_prefix(medium_provider) + "-" + pxe_file_names(medium_provider)[type.to_sym]
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
    if host.subnet&.httpboot? && host.pxe_loader =~ /UEFI HTTP/
      if host.pxe_loader =~ /HTTPS/
        port = host.subnet.httpboot.httpboot_https_port!
      else
        port = host.subnet.httpboot.httpboot_http_port!
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
    return becomes(family.constantize).use_release_name? unless self.class == family.constantize
    false
  end

  # Helper text shown next to major version (do not use i18n)
  def major_version_help
    '7'
  end

  # Helper text shown next to minor version (do not use i18n)
  def minor_version_help
    'e.g. 0 or 6.1810 (CentOS scheme)'
  end

  # Helper text shown next to release name (do not use i18n)
  def release_name_help
    'karmic, lucid, hw0910...'
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
    family || self.class.deduce_family(name)
  end

  apipie :method, 'Returns an array of boot file sources URIs' do
    required :medium_provider, 'MediumProviders::Provider', 'Medium provider responsible to provide location of installation medium for a given entity (host or host group)'
    block schema: '{ |vars| }', desc: 'Allows to adjust medium variables within the block'
    returns Array, desc: 'Array of boot file sources URIs'
  end
  def boot_files_uri(medium_provider, &block)
    boot_file_sources(medium_provider, &block).values
  end

  def url_for_boot(medium_provider, file, &block)
    boot_file_sources(medium_provider, &block)[file]
  end

  def pxe_file_names(medium_provider)
    family.constantize::PXEFILES
  end

  def boot_file_sources(medium_provider, &block)
    @boot_file_sources ||= pxe_file_names(medium_provider).transform_values do |img|
      img = medium_provider.interpolate_vars(img)
      "#{medium_provider.medium_uri(pxedir(medium_provider), &block)}/#{img}"
    end
  end

  def pxe_kernel_options(params)
    options = []
    options << params['kernelcmd'] if params['kernelcmd']
    options
  end

  apipie :method, 'Returns medium URI for given medium provider' do
    required :medium_provider, 'MediumProviders::Provider', desc: 'Medium provider'
    returns String, desc: 'Medium URI of given medium provider'
  end
  def mediumpath(medium_provider)
    medium_provider.medium_uri.to_s
  end

  def has_default_template?(template_kind)
    os_default_templates.find_by(template_kind: template_kind) || false
  end

  private

  def set_family
    self.family ||= deduce_family
  end

  def set_title
    self.title = to_label.to_s[0..254]
  end

  def stringify_major_and_minor
    # Cast major and minor to strings.
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

  def assign_init_config_template
    template_name = Setting[:default_host_init_config_template]
    template_kind = TemplateKind.unscoped.find_by(name: 'host_init_config')
    template = ProvisioningTemplate.unscoped.find_by(name: template_name, template_kind: template_kind)
    return unless template

    template.operatingsystems << self
    OsDefaultTemplate.create(template_kind: template_kind, provisioning_template: template, operatingsystem: self)
  end
end
