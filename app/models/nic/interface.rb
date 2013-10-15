module Nic
  class Interface < Base

    attr_accessible :ip

    validates :ip, :uniqueness => true, :presence => true, :format => {:with => Net::Validations::IP_REGEXP}

    validate :normalize_ip

    protected

    def uniq_fields_with_hosts
      [:mac, :ip]
    end

    def normalize_ip
      self.ip = Net::Validations.normalize_ip(ip)
    end

  end
end
