require 'securerandom'

# Common methods between host and hostgroup
# mostly for template rendering consistency
module HostCommon
  extend ActiveSupport::Concern
  extend ApipieDSL::Module
  include BelongsToProxies

  apipie :class, 'Common methods for Host and Host group objects' do
    name 'Host/group common'
    sections only: %w[all additional]
  end

  included do
    belongs_to_proxy :puppet_proxy,
      :feature => N_('Puppet'),
      :label => N_('Puppet Proxy'),
      :description => N_('Use the Puppetserver configured on this Smart Proxy'),
      :api_description => N_('Puppet proxy ID')

    belongs_to_proxy :puppet_ca_proxy,
      :feature => 'Puppet CA',
      :label => N_('Puppet CA Proxy'),
      :description => N_('Use the Puppetserver CA configured on this Smart Proxy'),
      :api_description => N_('Puppet CA proxy ID')

    belongs_to :architecture
    belongs_to :environment
    belongs_to :operatingsystem

    include SmartProxyHostExtensions

    belongs_to :medium
    belongs_to :ptable
    belongs_to :realm
    belongs_to :compute_profile
    belongs_to :compute_resource

    before_save :check_puppet_ca_proxy_is_required?, :crypt_root_pass
    has_many :host_config_groups, :as => :host
    has_many :config_groups, :through => :host_config_groups
    has_many :config_group_classes, :through => :config_groups
    has_many :group_puppetclasses, :through => :config_groups, :source => :puppetclasses

    alias_method :all_puppetclasses, :classes

    has_many :lookup_values, :primary_key => :lookup_value_matcher, :foreign_key => :match, :dependent => :destroy
    # See "def lookup_values_attributes=" under, for the implementation of accepts_nested_attributes_for :lookup_values
    accepts_nested_attributes_for :lookup_values

    before_save :set_lookup_value_matcher

    # Replacement of accepts_nested_attributes_for :lookup_values,
    # to work around the lack of `host_id` column in lookup_values.
    def lookup_values_attributes=(lookup_values_attributes)
      lookup_values_attributes.each do |_, attribute|
        attr = attribute.dup

        id = attr.delete(:id)
        if id.present?
          lookup_value = lookup_values.to_a.find { |i| i.id.to_i == id.to_i }
          if lookup_value
            mark_for_destruction = Foreman::Cast.to_bool(attr.delete(:_destroy))
            lookup_value.attributes = attr
            lookup_value.mark_for_destruction if mark_for_destruction
          end
        elsif !Foreman::Cast.to_bool(attr.delete(:_destroy))
          lookup_values.build(attr.merge(:match => lookup_value_match, :host_or_hostgroup => self))
        end
      end
    end
  end

  def parent_name
    if is_a?(Host::Base) && hostgroup
      hostgroup.name
    elsif is_a?(Hostgroup) && parent
      parent.name
    end
  end

  def medium_provider
    @medium_provider ||= Foreman::Plugin.medium_providers.find_provider(self)
  end

  apipie :method, 'Returns a url pointing to boot file' do
    required :file, Symbol, desc: 'File type to download from installation media associated with the host operating system. Accepted file types are based on host operating system, e.g. :kernel, :initrd'
    returns String, desc: 'The url for fetching the file'
    example "url_for_boot(:kernel) # => 'http://dl.fedoraproject.org/pub/fedora/linux/releases/29/Server/x86_64/os//images/pxeboot/vmlinuz'"
  end
  def url_for_boot(file)
    os.url_for_boot(medium_provider, file)
  end

  def puppetca?
    return false if respond_to?(:managed?) && !managed?
    puppetca_exists?
  end

  def puppetca_exists?
    !!(puppet_ca_proxy && puppet_ca_proxy.url.present?)
  end

  def puppet_server_uri
    return unless puppet_proxy
    url = puppet_proxy.setting('Puppet', 'puppet_url')
    url ||= "https://#{puppet_proxy}:8140"
    URI(url)
  end

  # The Puppet server FQDN or an empty string. Exposed as a provisioning macro
  def puppetmaster
    puppet_server_uri.try(:host) || ''
  end

  def puppet_ca_server_uri
    return unless puppet_ca_proxy
    url = puppet_ca_proxy.setting('Puppet CA', 'puppet_url')
    url ||= "https://#{puppet_ca_proxy}:8140"
    URI(url)
  end

  # The Puppet CA server FQDN or an empty string. Exposed as a provisioning
  # macro.
  def puppet_ca_server
    puppet_ca_server_uri.try(:host) || ''
  end

  # If the host/hostgroup has a medium then use the path from there
  # Else if the host/hostgroup's operatingsystem has only one media then use the image_path from that as this is automatically displayed when there is only one item
  # Else we cannot provide a default and it is cut and paste time
  def default_image_file
    return "" unless operatingsystem&.supports_image
    if medium
      nfs_path = medium.try :image_path
      if operatingsystem.try(:media) && operatingsystem.media.size == 1
        nfs_path ||= operatingsystem.media.first.image_path
      end
      # We encode the hw_model into the image file name as not all Sparc flashes can contain all possible hw_models. The user can always
      # edit it if required or use symlinks if they prefer.
      hw_model = model.try :hardware_model if defined?(model_id)
      medium_provider.interpolate_vars(nfs_path) + \
        "#{operatingsystem.file_prefix}.#{architecture}#{hw_model.empty? ? '' : '.' + hw_model.downcase}.#{operatingsystem.image_extension}"
    else
      ""
    end
  end

  def image_file=(file)
    # We only save a value into the image_file field if the value is not the default path, (which was placed in the entry when it was displayed,)
    # and it is not a directory, (ends in /)
    value = ((default_image_file == file) || (file =~ /\/\Z/) || file == "") ? nil : file
    self[:image_file] = value
  end

  def image_file
    super || default_image_file
  end

  def crypt_root_pass
    # hosts will always copy and crypt the password from parents when saved, but hostgroups should
    # only crypt if the attribute is stored, else will stay blank and inherit
    unencrypted_pass = if is_a?(Hostgroup)
                         self[:root_pass]
                       else
                         root_pass
                       end

    if unencrypted_pass.present?
      is_actually_encrypted = if (operatingsystem.try(:password_hash) == "Base64" || operatingsystem.try(:password_hash) == "Base64-Windows")
                                password_base64_encrypted?
                              elsif PasswordCrypt.crypt_gnu_compatible?
                                unencrypted_pass.match('^\$\d+\$.+\$.+')
                              else
                                unencrypted_pass.starts_with?("$")
                              end

      if is_actually_encrypted
        self.root_pass = self.grub_pass = unencrypted_pass
      else
        self.root_pass = operatingsystem.nil? ? PasswordCrypt.passw_crypt(unencrypted_pass) : PasswordCrypt.passw_crypt(unencrypted_pass, operatingsystem.password_hash)
        self.grub_pass = PasswordCrypt.grub2_passw_crypt(unencrypted_pass)
      end
    end
  end

  def cg_class_ids
    cg_ids = if is_a?(Hostgroup)
               path.each.map(&:config_group_ids).flatten.uniq
             else
               hostgroup ? hostgroup.path.each.map(&:config_group_ids).flatten.uniq : []
             end
    ConfigGroupClass.where(:config_group_id => (config_group_ids + cg_ids)).pluck(:puppetclass_id)
  end

  def hg_class_ids
    hg_ids = if is_a?(Hostgroup)
               path_ids
             elsif hostgroup
               hostgroup.path_ids
             end
    HostgroupClass.where(:hostgroup_id => hg_ids).pluck(:puppetclass_id)
  end

  def host_class_ids
    (is_a?(Host::Base) ? host_classes : hostgroup_classes).map(&:puppetclass_id)
  end

  def all_puppetclass_ids
    cg_class_ids + hg_class_ids + host_class_ids
  end

  def classes(env = environment)
    conditions = {:id => all_puppetclass_ids }
    if env
      env.puppetclasses.where(conditions)
    else
      Puppetclass.where(conditions)
    end
  end

  def puppetclass_ids
    classes.reorder('').pluck('puppetclasses.id')
  end

  def classes_in_groups
    conditions = {:id => cg_class_ids }
    if environment
      environment.puppetclasses.where(conditions) - parent_classes
    else
      Puppetclass.where(conditions) - parent_classes
    end
  end

  # Returns Puppetclasses of a Host or Hostgroup
  #
  # It does not include Puppetclasses of it's ConfigGroupClasses
  #
  def individual_puppetclasses
    ids = host_class_ids - cg_class_ids
    return puppetclasses if ids.blank? && new_record?
    Puppetclass.includes(:environments).where(id: ids)
  end

  def available_puppetclasses
    return Puppetclass.where(nil).authorized(:view_puppetclasses) if environment.blank?
    environment.puppetclasses - parent_classes
  end

  protected

  def set_lookup_value_matcher
    # in migrations, this method can get called before the attribute exists
    # the #attribute_names method is cached, so it's not going to be a performance issue
    return true unless self.class.attribute_names.include?("lookup_value_matcher")
    self.lookup_value_matcher = lookup_value_match
  end

  private

  # fall back to our puppet proxy in case our puppet ca is not defined/used.
  def check_puppet_ca_proxy_is_required?
    return true if puppet_ca_proxy_id.present? || puppet_proxy_id.blank?
    if puppet_proxy.has_feature?('Puppet CA')
      self.puppet_ca_proxy ||= puppet_proxy
    end
  rescue
    true # we don't want to break anything, so just skipping.
  end
end
