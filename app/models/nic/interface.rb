module Nic
  class Interface < Base
    before_validation :normalize_ip
    validate :ip_presence_and_formats

    validate :ip_uniqueness, :if => Proc.new { |i| i.ip.present? }
    validate :ip6_uniqueness, :if => Proc.new { |i| i.ip6.present? }
    validates :attached_to, :presence => true, :if => Proc.new { |o| o.virtual && o.instance_of?(Nic::Managed) && !o.bridge? }

    # Don't have to set a hostname for each interface, but it must be unique if it is set.
    before_validation :copy_hostname_from_host, :if => Proc.new { |nic| nic.primary? && nic.hostname.blank? }
    before_validation :normalize_name

    validates :name, :allow_nil => true, :allow_blank => true, :format => {:with => Net::Validations::HOST_REGEXP}

    validate :name_uniqueness, :if => Proc.new { |i| i.name.present? }

    # aliases and vlans require identifiers so we can differentiate and properly configure them
    validates :identifier, :presence => true, :if => Proc.new { |o| o.virtual? && o.managed? && o.instance_of?(Nic::Managed) }

    validate :alias_subnet

    delegate :network, :to => :subnet

    def vlanid
      self.tag.blank? ? self.subnet.vlanid : self.tag
    end

    def bridge?
      !!bridge
    end

    def bridge
      attrs[:bridge]
    end

    def alias?
      self.virtual? && self.identifier.present? && self.identifier.include?(':')
    end

    def fqdn_changed?
      name_changed? || domain_id_changed?
    end

    def fqdn_was
      domain_was = Domain.find(domain_id_was) unless domain_id_was.blank?
      return name_was if name_was.blank? || domain_was.blank?
      name_was.include?('.') ? name_was : "#{name_was}.#{domain_was}"
    end

    protected

    def ip_uniqueness
      interface_attribute_uniqueness(:ip)
    end

    def ip6_uniqueness
      interface_attribute_uniqueness(:ip6)
    end

    def name_uniqueness
      interface_attribute_uniqueness(:name, Nic::Base.where(:domain_id => self.domain_id))
    end

    def ip_presence_and_formats
      errors.add(:ip, _("is invalid")) if ip.present? && !Net::Validations.validate_ip(ip)
      errors.add(:ip6, _("is invalid")) if ip6.present? && !Net::Validations.validate_ip6(ip6)
    end

    def alias_subnet
      if self.managed? && self.alias? && self.subnet && self.subnet.boot_mode != Subnet::BOOT_MODES[:static]
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
      self.name.gsub!(/\s/,'') if self.name
      # no hostname was given or a domain was selected, since this is before validation we need to ignore
      # it and let the validations to produce an error
      return if name.empty?
      if domain.nil? && name.include?('.') && !changed_attributes['domain_id'].present?
        # try to assign the domain automatically based on our existing domains from the host FQDN
        self.domain = Domain.find_by(:name => name.partition('.')[2])
      elsif persisted? && changed_attributes['domain_id'].present?
        # if we've just updated the domain name, strip off the old one
        old_domain = Domain.find(changed_attributes["domain_id"])
        # Remove the old domain, until fqdn will be set as the full name
        self.name.chomp!("." + old_domain.to_s)
      end
      # name should be fqdn
      self.name = fqdn
      # A managed host we should know the domain for; and the shortname shouldn't include a period
      # This only applies for unattended=true, as otherwise the name field includes the domain
      errors.add(:name, _("must not include periods")) if (host && host.managed? && managed? && shortname.include?(".") && SETTINGS[:unattended])
      self.name = Net::Validations.normalize_hostname(name) if self.name.present?
    end
  end
end

require_dependency 'nic/managed'
