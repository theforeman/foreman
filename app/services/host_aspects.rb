module HostAspects
  class << self
    def configuration
      @configuration ||= HostAspects::Configuration.new
    end

    def configure(&block)
      configuration.instance_eval(&block)
    end
  end
end
