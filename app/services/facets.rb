module Facets
  class << self
    def configuration
      @configuration ||= Facets::Configuration.new
    end

    def configure(&block)
      configuration.instance_eval(&block)
    end
  end
end
