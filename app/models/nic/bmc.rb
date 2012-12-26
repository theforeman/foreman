module Nic
  class BMC < Managed

    ATTRIBUTES = [:username, :password, :provider]
    attr_accessible *ATTRIBUTES

    PROVIDERS = %w(IPMI)
    validates_inclusion_of :provider, :in => PROVIDERS

    ATTRIBUTES.each do |method|
      define_method method do
        self.attrs ||= { }
        self.attrs[method]
      end

      define_method "#{method}=" do |value|
        self.attrs         ||= { }
        self.attrs[method] = value
      end
    end
  end
end