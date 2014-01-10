require 'fog_extensions'
class ComputeResource < ActiveRecord::Base
  include Taxonomix
  include Encryptable
  include Authorizable
  encrypts :password
  SUPPORTED_PROVIDERS = %w[Libvirt Ovirt EC2 Vmware Openstack Rackspace GCE]
  PROVIDERS = SUPPORTED_PROVIDERS.reject { |p| !SETTINGS[p.downcase.to_sym] }
  audited :except => [:password, :attrs], :allow_mass_assignment => true
  serialize :attrs, Hash
  has_many :trends, :as => :trendable, :class_name => "ForemanTrend"

  # to STI avoid namespace issues when loading the class, we append Foreman::Model in our database type column
  STI_PREFIX= "Foreman::Model"

  before_destroy EnsureNotUsedBy.new(:hosts)
  has_and_belongs_to_many :users, :join_table => "user_compute_resources"
  validates :name, :uniqueness => true, :format => { :with => /\A(\S+)\Z/, :message => N_("can't be blank or contain white spaces.") }
  validates :provider, :presence => true, :inclusion => { :in => PROVIDERS }
  validates :url, :presence => true
  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :id, :complete_value => :true
  before_save :sanitize_url
  has_many_hosts
  has_many :images, :dependent => :destroy
  before_validation :set_attributes_hash
  has_many :compute_attributes
  has_many :compute_profiles, :through => :compute_attributes
  # attribute used by *_names and *_name methods.  default is :name
  attr_name :to_label

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("compute_resources.name")
    end
  }

  scope :my_compute_resources, lambda {
    user = User.current
    if user.admin?
      conditions = { }
    else
      conditions = sanitize_sql_for_conditions([" (compute_resources.id in (?))", user.compute_resource_ids])
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    where(conditions).reorder('type, name')
  }

  # allows to create a specific compute class based on the provider.
  def self.new_provider args
    raise ::Foreman::Exception.new(N_("must provide a provider")) unless provider = args[:provider]
    PROVIDERS.each do |p|
      return "#{STI_PREFIX}::#{p}".constantize.new(args) if p.downcase == provider.downcase
    end
    raise ::Foreman::Exception.new N_("unknown provider")
  end

  def capabilities
    []
  end

  # attributes that this provider can provide back to the host object
  def provided_attributes
    {:uuid => :identity}
  end

  def test_connection options = {}
    valid?
  end

  def ping
    test_connection
    errors
  end

  def save_vm uuid, attr
    vm = find_vm_by_uuid(uuid)
    vm.attributes.merge!(attr.symbolize_keys)
    vm.save
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def to_label
    "#{name} (#{provider_friendly_name})"
  end

  def provider_friendly_name
    list = SETTINGS[:libvirt] ? ["Libvirt"] : []
    list += %w[ oVirt EC2 VMWare OpenStack Rackspace Google]
    list[PROVIDERS.index(provider)] rescue ""
  end

  def image_param_name
    :image_id
  end

  # returns a new fog server instance
  def new_vm attr={}
    test_connection
    client.servers.new vm_instance_defaults.merge(attr.to_hash.symbolize_keys) if errors.empty?
  end

  # return fog new interface ( network adapter )
  def new_interface attr={}
    client.interfaces.new attr
  end

  # return a list of virtual machines
  def vms(opts = {})
    client.servers
  end

  def find_vm_by_uuid uuid
    client.servers.get(uuid) || raise(ActiveRecord::RecordNotFound)
  end

  def start_vm uuid
    find_vm_by_uuid(uuid).start
  end

  def stop_vm uuid
    find_vm_by_uuid(uuid).stop
  end

  def create_vm args = {}
    options = vm_instance_defaults.merge(args.to_hash.symbolize_keys)
    logger.debug("creating VM with the following options: #{options.inspect}")
    client.servers.create options
  rescue Fog::Errors::Error => e
    logger.debug "Fog error: #{e.message}\n " + e.backtrace.join("\n ")
    errors.add(:base, e.message.to_s)
    false
  end

  def destroy_vm uuid
    find_vm_by_uuid(uuid).destroy
  rescue ActiveRecord::RecordNotFound
    # if the VM does not exists, we don't really care.
    true
  end

  def provider
    read_attribute(:type).to_s.gsub("#{STI_PREFIX}::","")
  end

  def provider=(value)
    if PROVIDERS.include? value
      self.type = "#{STI_PREFIX}::#{value}"
    end
  end

  def vm_instance_defaults
    ActiveSupport::HashWithIndifferentAccess.new(:name => "foreman_#{Time.now.to_i}")
  end

  def templates(opts={})
  end

  def template(id,opts={})
  end

  def update_required?(old_attrs, new_attrs)
    old_attrs.merge(new_attrs) do |k,old_v,new_v|
      update_required?(old_v, new_v) if old_v.is_a?(Hash)
      return true unless old_v == new_v
      new_v
    end
    false
  end

  def console uuid = nil
    raise ::Foreman::Exception.new(N_("%s console is not supported at this time"), provider)
  end

  # by default, our compute providers do not support updating an existing instance
  def supports_update?
    false
  end

  def available_images
    []
  end

  def set_console_password?
    self.attrs[:setpw] == 1 || self.attrs[:setpw].nil?
  end

  def set_console_password=(setpw)
    self.attrs[:setpw] = setpw.to_i
  end

  def compute_profile_attributes_for(id)
    compute_attributes.find_by_compute_profile_id(id).try(:vm_attrs) || {}
  end

  protected

  def client
    raise ::Foreman::Exception.new N_("Not implemented")
  end

  def sanitize_url
    self.url.chomp!("/") unless url.empty?
  end

  def random_password
    return nil unless set_console_password?
    n = 8
    chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
    (0...n).map { chars[rand(chars.length)].chr }.join
  end

  def nested_attributes_for type, opts
    return [] unless opts
    opts = opts.dup #duplicate to prevent changing the origin opts.
    opts.delete("new_#{type}") # delete template
    # convert our options hash into a sorted array (e.g. to preserve nic / disks order)
    opts = opts.sort { |l, r| l[0].sub('new_','').to_i <=> r[0].sub('new_','').to_i }.map { |e| Hash[e[1]] }
    opts.map do |v|
      if v[:"_delete"] == '1'  && v[:id].blank?
        nil
      else
        v.symbolize_keys # convert to symbols deeper hashes
      end
    end.compact
  end

  private

  def set_attributes_hash
    self.attrs ||= {}
  end

end
