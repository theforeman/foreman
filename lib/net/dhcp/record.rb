module Net::DHCP
  class Record < Net::Record
    attr_accessor :name, :ip, :mac, :network, :nextServer, :filename, :related_macs, :type

    def initialize(opts = { })
      super(opts)
      self.related_macs ||= []
      self.mac     = Net::Validations.validate_mac! self.mac
      self.network = Net::Validations.validate_network! self.network
      self.ip      = Net::Validations.validate_ip! self.ip
      self.type    = opts["type"]
    end

    def legacy_dhcp_api?
      type.nil?
    end

    def lease?
      type && type == "lease"
    end

    def reservation?
      !lease?
    end

    def to_s
      "#{hostname}-#{mac}/#{ip}"
    end

    # Deletes the DHCP entry
    def destroy
      logger.info "Delete DHCP reservation #{name} for #{self}"
      # it is safe to call destroy even if the entry does not exists, so we don't bother with validating anything here.
      proxy.delete network, mac
    end

    # Create a DHCP entry
    def create
      logger.info "Create DHCP reservation #{name} for #{self}"
      logger.debug "DHCP reservation on net #{network} with attrs: #{attrs.inspect}"
      begin
        raise "Must define a hostname" if hostname.blank?
        proxy.set network, attrs
      rescue RestClient::Conflict
        logger.warn "Conflicting DHCP reservation for #{self} detected"
        e          = Net::Conflict.new
        e.type     = "dhcp"
        e.expected = to_s
        e.actual   = conflicts
        e.message  = "in DHCP detected - expected #{self}, found #{conflicts.map(&:to_s).join(', ')}"
        raise e
      end
    end

    # Returns an array of record objects which are conflicting with our own
    def conflicts
      conflicts = [proxy.record(network, mac), proxy.records_by_ip(network, ip)].flatten.compact.delete_if { |c| c.lease? || c == self || related_macs.include?(c.mac) }
      @conflicts ||= conflicts.uniq {|c| c.attrs}
    end

    # Verifies that a record already exists on the dhcp server
    def valid?
      logger.info "Fetching DHCP reservation #{name} for #{self}"
      self == proxy.record(network, mac)
    end

    def ==(other)
      return false unless other.present?
      to_compare = [:mac, :ip, :network]

      # If we're converting an 'ad-hoc' lease created by a host booting outside of Foreman's knowledge,
      # then :hostname will be blank on the incoming lease - if the ip/mac still match, then this
      # isn't a conflict. Only applicable on legacy proxy API without "type" attribute.
      if legacy_dhcp_api?
        to_compare << :hostname if other.attrs[:hostname].present? && attrs[:hostname].present?
      end

      # Not all DHCP smart-proxy providers support TFTP filename option (e.g. libvirt).
      to_compare << :filename if other.attrs[:filename].present? && attrs[:filename].present?

      logger.debug "Comparing #{attrs.values_at(*to_compare)} == #{other.attrs.values_at(*to_compare)}"
      attrs.values_at(*to_compare) == other.attrs.values_at(*to_compare)
    end

    def attrs
      @attrs ||= {
        :hostname => hostname,
        :mac => mac,
        :ip => ip,
        :network => network,
        :nextServer => nextServer,
        :filename => filename,
        :name => name,
        :related_macs => related_macs,
        :type => type
      }.compact
    end
  end
end
