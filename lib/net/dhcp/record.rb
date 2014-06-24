module Net::DHCP
  class Record < Net::Record
    attr_accessor :ip, :mac, :network, :nextServer, :filename

    def initialize opts = { }
      super(opts)
      self.mac     = validate_mac self.mac
      self.network = validate_network self.network
      self.ip      = validate_ip self.ip
    end

    def to_s
      "#{hostname}-#{mac}/#{ip}"
    end

    # Deletes the DHCP entry
    def destroy
      logger.info "Delete DHCP reservation for #{to_s}"
      # it is safe to call destroy even if the entry does not exists, so we don't bother with validating anything here.
      proxy.delete network, mac
    end

    # Create a DHCP entry
    def create
      logger.info "Create DHCP reservation for #{to_s}"
      begin
        raise "Must define a hostname" if hostname.blank?
        proxy.set network, attrs
      rescue RestClient::Conflict
        logger.warn "Conflicting DHCP reservation for #{to_s} detected"
        e          = Net::Conflict.new
        e.type     = "dhcp"
        e.expected = to_s
        e.actual   = conflicts
        e.message  = "in DHCP detected - expected #{to_s}, found #{conflicts.map(&:to_s).join(', ')}"
        raise e
      end
    end

    # Returns an array of record objects which are conflicting with our own
    def conflicts
      conflicts = [proxy.record(network, mac), proxy.record(network, ip)].delete_if { |c| c == self }.compact
      @conflicts ||= conflicts.uniq {|c| c.attrs}
    end

    # Verifies that are record already exists on the dhcp server
    def valid?
      logger.info "Fetching DHCP reservation for #{to_s}"
      self == proxy.record(network, mac)
    end

    def == other
      return false unless other.present?
      if attrs[:hostname].blank?
        # If we're converting an 'ad-hoc' lease created by a host booting outside of Foreman's knowledge,
        # then :hostname will be blank on the incoming lease - if the ip/mac still match, then this
        # isn't a conflict
        attrs.values_at(:mac, :ip, :network) == other.attrs.values_at(:mac, :ip, :network)
      else
        # Otherwise, if a hostname is present, we want to check all 4 match before declaring a conflict
        attrs.values_at(:hostname, :mac, :ip, :network) == other.attrs.values_at(:hostname, :mac, :ip, :network)
      end
    end

    def attrs
      { :hostname   => hostname, :mac => mac, :ip => ip, :network => network,
        :nextServer => nextServer, :filename => filename
      }.delete_if { |k, v| v.nil? }
    end
  end
end
