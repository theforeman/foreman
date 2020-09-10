module IPAM
  class Base
    # Requirements for ActiveModel::Errors
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    delegate :logger, :to => :Rails
    attr_accessor :mac, :subnet, :excluded_ips
    attr_reader :errors

    def initialize(opts = {})
      @subnet = opts[:subnet]
      @excluded_ips = opts[:excluded_ips] || []
      @mac = opts.fetch(:mac, nil)
      @mac = nil if @mac.try(:blank?)
      @errors = ActiveModel::Errors.new(self)

      normalize_mac!
    end

    def subnet_range
      @subnet_range ||= begin
        subnet_range = IPAddr.new("#{subnet.network}/#{subnet.mask}", subnet.family).to_range
        # exclude first element - network
        from = subnet.from.present? ? IPAddr.new(subnet.from) : subnet_range.first(2).last
        # exclude last element - broadcast
        to = subnet.to.present? ? IPAddr.new(subnet.to) : IPAddr.new(subnet_range.last.to_i - 2, subnet.family)
        logger.debug "IPAM #{self.class.name} searching range #{from} - #{to}"
        (from..to)
      end
    end

    def suggest_new?
      true
    end

    # Requirement for Subnet#as_json
    def serializable_hash(options = nil)
      {'suggest_new' => suggest_new?}
    end

    private

    def normalize_mac!
      return unless mac.present?
      self.mac = Net::Validations.normalize_mac(mac)
    rescue Net::Validations::Error
      errors.add(:mac, _('is not a valid MAC address'))
    end

    # Requirement for ActiveModel::Errors
    def read_attribute_for_validation(attr)
      send(attr)
    end
  end
end
