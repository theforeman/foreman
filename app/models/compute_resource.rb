require 'fog_extensions'
class ComputeResource < ActiveRecord::Base
  PROVIDERS = %w[ Libvirt Ovirt EC2 Vmware ].delete_if{|p| p == "Libvirt" && !SETTINGS[:libvirt]}
  acts_as_audited :except => [:password]

  # to STI avoid namespace issues when loading the class, we append Foreman::Model in our database type column
  STI_PREFIX= "Foreman::Model"

  before_destroy EnsureNotUsedBy.new(:hosts)
  include Authorization
  has_and_belongs_to_many :users, :join_table => "user_compute_resources"
  validates_format_of :name, :with => /\A(\S+)\Z/, :message => "can't be blank or contain white spaces."
  validates_uniqueness_of :name
  validates_presence_of :provider, :in => PROVIDERS
  validates_presence_of :url
  scoped_search :on => :name, :complete_value => :true
  before_save :sanitize_url
  has_many :hosts
  has_many :images, :dependent => :destroy

  default_scope :order => 'LOWER(compute_resources.name)'

  scope :my_compute_resources, lambda {
    user = User.current
    if user.admin?
      conditions = { }
    else
      conditions = sanitize_sql_for_conditions([" (compute_resources.id in (?))", user.compute_resources.map(&:id)])
      conditions.sub!(/\s*\(\)\s*/, "")
      conditions.sub!(/^(?:\(\))?\s?(?:and|or)\s*/, "")
      conditions.sub!(/\(\s*(?:or|and)\s*\(/, "((")
    end
    {:conditions => conditions}
  }

  # allows to create a specific compute class based on the provider.
  def self.new_provider args
    raise "must provide a provider" unless provider = args[:provider]
    PROVIDERS.each do |p|
      return eval("#{STI_PREFIX}::#{p}").new(args) if p.downcase == provider.downcase
    end
    raise "unknown Provider"
  end

  def capabilities
    []
  end

  # attributes that this provider can provide back to the host object
  def provided_attributes
    {:uuid => :identity}
  end

  def test_connection
    valid?
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
    list += %w[ oVirt EC2 VMWare ]
    list[PROVIDERS.index(provider)]
  end

  # returns a new fog server instance
  def new_vm attr={}
    client.servers.new vm_instance_defaults.merge(attr)
  end

  # return fog new interface ( network adapter )
  def new_interface attr={}
    client.interfaces.new attr
  end

  # return a list of virtual machines
  def vms
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
    client.servers.create vm_instance_defaults.merge(args.to_hash)
  rescue Fog::Errors::Error => e
    logger.debug "Fog error: #{e.message}\n " + e.backtrace.join("\n ")
    errors.add(:base, e.message.to_s)
    false
  end

  def destroy_vm uuid
    find_vm_by_uuid(uuid).destroy
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
    {
      'name' => "foreman_#{Time.now.to_i}",
    }
  end

  def hardware_profiles(opts={})
  end

  def hardware_profile(id,opts={})
  end

  def update_required?(old_attrs, new_attrs)
    old_attrs.merge(new_attrs) do |k,old_v,new_v|
      update_required?(old_v, new_v) if old_v.is_a?(Hash)
      return true unless old_v == new_v
      new_v
    end
    false
  end

  def as_json(options={})
    super({:except => [:password]}.merge(options))
  end

  def console uuid = nil
    raise "#{provider} console is not supported at this time"
  end

  protected

  def client
    raise "Not implemented"
  end

  def sanitize_url
    self.url.chomp!("/") unless url.empty?
  end

  def random_password
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

  def enforce_permissions operation
    # We get called again with the operation being set to create
    return true if operation == "edit" and new_record?
    current = User.current
    if current.allowed_to?("#{operation}_compute_resources".to_sym)
      # If you can create compute resources then you can create them anywhere
      return true if operation == "create"
      # edit or delete
      if current.allowed_to?("#{operation}_compute_resources".to_sym)
        return true if ComputeResource.my_compute_resources(current).include? self
      end
    end
    errors.add :base, "You do not have permission to #{operation} this compute resource"
    false
  end

end
