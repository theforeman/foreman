module Resolvers
  class Generic
    def initialize(type)
      @type = type
    end

    def self.for(type)
      new(type)
    end

    def record
      return unless model_class
      base_class.include(Resolvers::Concerns::Record)
    end

    def collection
      return unless model_class
      base_class.include(Resolvers::Concerns::Collection)
    end

    private

    attr_reader :type
    delegate :model_class, to: :type

    def base_class
      Class.new(Resolvers::BaseResolver).tap do |c|
        c.const_set('MODEL_CLASS', model_class)
      end
    end
  end
end
