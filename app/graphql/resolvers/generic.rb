module Resolvers
  class Generic
    def initialize(model)
      @model = model
    end

    def self.for(model)
      new(model)
    end

    def record
      return unless model
      base_class.include(Resolvers::Concerns::Record)
    end

    def collection
      return unless model
      base_class.include(Resolvers::Concerns::Collection)
    end

    private

    attr_reader :model

    def base_class
      Class.new(Resolvers::BaseResolver).tap do |c|
        c.const_set('MODEL_CLASS', model)
      end
    end
  end
end
