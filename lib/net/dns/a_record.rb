module Net
  module DNS
    class ARecord < DNS::ForwardRecord
      def initialize(opts = { })
        super opts
        self.ip = validate_ip! self.ip
        self.ipversion = 4
        @type = "A"
      end
    end
  end
end

