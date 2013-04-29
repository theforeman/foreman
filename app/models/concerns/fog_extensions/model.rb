module FogExtensions
  module Model
    extend ActiveSupport::Concern

    included do
      attr_accessor :_delete
    end

    def persisted?
      !!identity
    end

    def to_json(options={ })
      ActiveSupport::JSON.encode(self, options)
    end

    def as_json(options = { })
      attr = attributes.dup
      attr.delete(:client)
      attr
    end
  end
end