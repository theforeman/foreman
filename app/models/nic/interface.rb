module Nic
  class Interface < Base
    before_validation :normalize_ip
    validate :ip_presence_and_formats

    validate :ip_uniqueness, :if => proc { |i| i.ip.present? }
    validate :ip6_uniqueness, :if => proc { |i| i.ip6.present? }
    validates :attached_to, :presence => true, :if => proc { |o| o.virtual && o.instance_of?(Nic::Managed) && !o.bridge? }

    # Don't have to set a hostname for each interface, but it must be unique if it is set.
    before_validation :copy_hostname_from_host, :if => proc { |nic| nic.primary? && nic.hostname.blank? }
    before_validation :normalize_name

    validates :name, :allow_nil => true, :allow_blank => true, :format => {:with => Net::Validations::HOST_REGEXP, :message => _(Net::Validations::HOST_REGEXP_ERR_MSG)}

    validate :name_uniqueness, :if => proc { |i| i.name.present? }

    # aliases and vlans require identifiers so we can differentiate and properly configure them
    validates :identifier, :presence => true, :if => proc { |o| o.virtual? && o.managed? && o.instance_of?(Nic::Managed) }

    validate :alias_subnet

    delegate :network, :to => :subnet, :prefix => true
    delegate :network, :to => :subnet6, :prefix => true

    alias_method :network, :subnet_network
    alias_method :network6, :subnet6_network

    def vlanid
      # Determine a vlanid according to the following cascading rules:
      # 1. if the interface has a tag, use that as the vlanid
      # 2. if the interface has a v4 subnet with a non-blank vlanid, use that
      # 3. if the interface has a v6 subnet with a non-blank vlanid, use that
      # 4. if no reasonable vlanid was determined, then return an empty string
      #
      # In case the v4 and v6 subnet are both present, they should have the same
      # vlanid. If they have a different vlanid, this is probably an error in the
      # user's database. There is no way of determining the real vlanid, so we
      # pick the v4 one unless it turns out to be blank.

      return tag if tag.present?
      return subnet.vlanid if subnet && subnet.vlanid.present?
      return subnet6.vlanid if subnet6 && subnet6.vlanid.present?
      ''
    end

    def mtu
      # Determine a mtu according to the following cascading rules:
      # 1. if the interface has a v4 subnet with a non-blank mtu, use that
      # 2. if the interface has a v6 subnet with a non-blank mtu, use that
      # 3. if no reasonable mtu was determined, then return nil
      #
      # In case the v4 and v6 subnet are both present, they should have the same
      # mtu. If they have a different mtu, this is probably an error in the
      # user's database. There is no way of determining the real mtu, so we
      # pick the v4 one unless it turns out to be blank.

      return attrs['mtu'] if attrs['mtu'].present?
      return subnet.mtu if subnet && subnet.mtu.present?
      return subnet6.mtu if subnet6 && subnet6.mtu.present?
      nil
    end

    def bridge?
      !!bridge
    end

    def bridge
      attrs[:bridge]
    end

    def alias?
      virtual? && identifier.present? && identifier.include?(':')
    end

    def saved_change_to_fqdn?
      saved_change_to_name? || saved_change_to_domain_id?
    end

    def fqdn_before_last_save
      domain_before_last_save = Domain.unscoped.find(domain_id_before_last_save) if domain_id_before_last_save.present?
      return name_before_last_save if name_before_last_save.blank? || domain_before_last_save.blank?
      name_before_last_save.include?('.') ? name_before_last_save : "#{name_before_last_save}.#{domain_before_last_save}"
    end

    protected

    def ip_uniqueness
      interface_attribute_uniqueness(:ip)
    end

    def ip6_uniqueness
      interface_attribute_uniqueness(:ip6)
    end

    def name_uniqueness
      interface_attribute_uniqueness(:name, Nic::Base.where(:domain_id => domain_id))
    end

    def ip_presence_and_formats
      errors.add(:ip, _("is invalid")) if ip.present? && !Net::Validations.validate_ip(ip)
      errors.add(:ip6, _("is invalid")) if ip6.present? && !Net::Validations.validate_ip6(ip6)
    end

    def alias_subnet
      if managed? && alias? && subnet && subnet.boot_mode != Subnet::BOOT_MODES[:static]
        errors.add(:subnet_id, _('subnet boot mode is not %s' % _(Subnet::BOOT_MODES[:static])))
      end
    end

    def normalize_ip
      self.ip = Net::Validations.normalize_ip(ip) if ip.present?
      self.ip6 = Net::Validations.normalize_ip6(ip6) if ip6.present?
    end

    # ensure that host name is fqdn
    # if the user inputted short name, the domain name will be appended
    # this is done to ensure compatibility with puppet storeconfigs
    def normalize_name
      # Remove whitespace
      self.name = name.gsub(/\s/, '') if name
      # no hostname was given or a domain was selected, since this is before validation we need to ignore
      # it and let the validations to produce an error
      return if name.empty?
      if domain_id.nil? && name.include?('.') && changed_attributes['domain_id'].blank?
        # try to assign the domain automatically based on our existing domains from the host FQDN
        self.domain = Domain.unscoped.find_by(:name => name.partition('.')[2])
      elsif persisted? && changed_attributes['domain_id'].present?
        # if we've just updated the domain name, strip off the old one
        old_domain = Domain.unscoped.find(changed_attributes["domain_id"])
        # Remove the old domain, until fqdn will be set as the full name
        self.name = name.chomp('.' + old_domain.to_s)
      end
      # name should be fqdn
      self.name = fqdn
      # A managed host we should know the domain for; and the shortname shouldn't include a period
      errors.add(:name, _("must not include periods")) if (host&.managed? && managed? && shortname.include?("."))
      self.name = Net::Validations.normalize_hostname(name) if name.present?
    end
  end
end

require_dependency 'nic/managed'
