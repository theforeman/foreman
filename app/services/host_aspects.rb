module HostAspects
  class << self
    def configuration
      @configuration ||= HostAspects::Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end