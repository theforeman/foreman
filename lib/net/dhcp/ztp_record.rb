module Net::DHCP
  class ZTPRecord < Record
    attr_accessor :firmware, :vendor

    def initialize(opts = { })
      super(opts)
      self.firmware    = opts[:firmware]
      self.vendor      = opts[:vendor]
    end

    def attrs
      @attrs ||= super.merge(
        {
          :ztp_firmware   => firmware,
          :ztp_vendor     => vendor,
        }).compact
    end
  end
end
