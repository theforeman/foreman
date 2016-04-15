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
      @excluded_ips = opts.fetch(:excluded_ips, [])
      @mac = opts.fetch(:mac, nil)
      @errors = ActiveModel::Errors.new(self)

      normalize_mac!
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
      return unless self.mac.present?
      self.mac = Net::Validations.normalize_mac(self.mac)
    rescue Net::Validations::Error
      errors.add(:mac, _('is not a valid MAC address'))
    end

    # Requirement for ActiveModel::Errors
    def read_attribute_for_validation(attr)
      send(attr)
    end
  end
end
