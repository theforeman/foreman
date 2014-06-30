module Nic
  class Interface < Base

    attr_accessible :ip

    validates :ip, :uniqueness => true, :format => {:with => Net::Validations::IP_REGEXP}, :allow_blank => true

    validate :normalize_ip

    validates :physical_device, :presence => true, :if => Proc.new { |o| o.virtual && !o.bridge }

    attr_accessible :name, :subnet_id, :subnet, :domain_id, :domain

    # Don't have to set a hostname for each interface, but it must be unique if it is set.
    before_validation :normalize_name

    validates :name,  :uniqueness => {:scope => :domain_id},
              :allow_nil => true,
              :allow_blank => true,
              :format => {:with => Net::Validations::HOST_REGEXP}

    belongs_to :subnet
    belongs_to :domain

    delegate :network, :to => :subnet

    def vlanid
      self.tag.blank? ? self.subnet.vlanid : self.tag
    end

    def bridge
      attrs[:bridge]
    end

    protected

    def uniq_fields_with_hosts
      super + (self.virtual? ? [] : [:ip])
    end

    def normalize_ip
      self.ip = Net::Validations.normalize_ip(ip)
    end

    def normalize_name
      self.name = Net::Validations.normalize_hostname(name) if self.name.present?
    end

  end
end
