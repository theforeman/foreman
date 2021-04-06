module IPAM
  class Base
    # Requirements for ActiveModel::Errors
    extend ActiveModel::Naming
    extend ActiveModel::Translation

    delegate :logger, :to => :Rails
    attr_accessor :mac, :subnet, :excluded_ips, :block_ip_minutes
    attr_reader :errors

    BLOCK_IP_MINUTES_DEFAULT = 30

    def initialize(opts = {})
      @subnet = opts[:subnet]
      @excluded_ips = opts[:excluded_ips] || []
      @mac = opts.fetch(:mac, nil)
      @mac = nil if @mac.try(:blank?)
      @errors = ActiveModel::Errors.new(self)
      @block_ip_minutes = opts.fetch(:block_ip_minutes, BLOCK_IP_MINUTES_DEFAULT)

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

    def block_ip_cache_key(ip)
      "blocked_ip_cache_#{subnet.id}/#{ip}"
    end

    def block_ip(ip)
      Rails.cache.write(block_ip_cache_key(ip), 'blocked', expires_in: block_ip_minutes.minutes)
    end

    def is_ip_blocked?(ip)
      Rails.cache.exist?(block_ip_cache_key(ip))
    end

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
