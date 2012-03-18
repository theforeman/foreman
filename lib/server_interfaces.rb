require 'fog'

module Fog
  class Model

    attr_accessor :_delete

    def persisted?
      !!identity
    end

    def to_json(options={})
      ActiveSupport::JSON.encode(self, options)
    end

    def as_json(options = {})
      attr = attributes.dup
      attr.delete(:client)
      attr
    end

    def interfaces_attributes= attrs
      @interfaces_attributes = attrs
    end

  end
end