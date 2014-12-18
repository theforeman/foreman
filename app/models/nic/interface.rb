module Nic
  class Interface < Base
    validates :ip, :uniqueness => true, :format => {:with => Net::Validations::IP_REGEXP}, :allow_blank => true

    validate :normalize_ip

    validates :attached_to, :presence => true, :if => Proc.new { |o| o.virtual && o.instance_of?(Nic::Managed) && !o.bridge? }

    # Don't have to set a hostname for each interface, but it must be unique if it is set.
    before_validation :copy_hostname_from_host, :if => Proc.new { |nic| nic.primary? && nic.hostname.blank? }
    before_validation :normalize_name

    validates :name,  :uniqueness => {:scope => :domain_id},
              :allow_nil => true,
              :allow_blank => true,
              :format => {:with => Net::Validations::HOST_REGEXP}

    # aliases and vlans require identifiers so we can differentiate and properly configure them
    validates :identifier, :presence => true, :if => Proc.new { |o| o.virtual? && o.managed? && o.instance_of?(Nic::Managed) }
    validate :identifier_change, :on => :update

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

    # we don't allow changes to identifier which would change the interface type e.g. eth0 -> eth0,1 would make
    # a vlan virtual interface from physical one
    def identifier_change
      old_value = self.identifier_was || ''
      new_value = self.identifier || ''

      %w(. :).each do |forbidden|
        if old_value.include?(forbidden) != new_value.include?(forbidden)
          errors.add(:identifier, _("Can't add or remove `%s` from identifier") % forbidden)
        end
      end
    end

    def alias_subnet
      if self.managed? && self.alias? && self.subnet && self.subnet.boot_mode != Subnet::BOOT_MODES[:static]
        errors.add(:subnet_id, _('subnet boot mode is not %s' % _(Subnet::BOOT_MODES[:static])))
      end
    end

    def uniq_fields_with_hosts
      super + (self.virtual? ? [] : [:ip])
    end

    def normalize_ip
      self.ip = Net::Validations.normalize_ip(ip)
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
      if domain.nil? && name.match(/\./) && !changed_attributes['domain_id'].present?
        # try to assign the domain automatically based on our existing domains from the host FQDN
        self.domain = Domain.all.select{|d| name.match(/#{d.name}\Z/)}.first rescue nil
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
      errors.add(:name, _("must not include periods")) if ( host && host.managed? && managed? && shortname.include?(".") && SETTINGS[:unattended] )
      self.name = Net::Validations.normalize_hostname(name) if self.name.present?
    end
  end
end

require_dependency 'nic/managed'
