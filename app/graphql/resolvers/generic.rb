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

    def association(association_name)
      return unless model_class
      base_class.tap do |c|
        c.const_set('ASSOC_NAME', association_name)
      end.include(Resolvers::Concerns::Association)
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
