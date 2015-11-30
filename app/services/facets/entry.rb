module Facets
  class Entry
    ATTRIBUTES = [:name, :model, :helper, :extension, :tabs]
    attr_accessor(*ATTRIBUTES)

    ATTRIBUTES.each do |attr|
      define_method "#{attr}_class".to_sym do
        sym = self.send(attr)
        to_class(sym)
      end
    end

    def initialize(facet_name, facet_model)
      self.name = to_name(facet_name)
      self.model = to_model(facet_model)
    end

    def add_helper(facet_helper)
      self.helper = facet_helper.try(:to_sym)
    end

    def add_tabs(tabs)
      raise ArgumentError, 'tabs should be a hash or a helper method symbol' unless tabs.is_a?(Hash) || tabs.is_a?(Symbol)
      self.tabs = tabs
    end

    def extend_model(extension_symbol)
      self.extension = to_symbol(extension_symbol)
    end

    private

    def to_name(facet_name)
      to_symbol(facet_name)
    end

    def to_model(facet_model)
      to_symbol(facet_model) || self.name
    end

    private

    def to_class(symbol)
      symbol.to_s.camelize.constantize if symbol
    end

    def to_symbol(input)
      return nil unless input
      input = input.name if input.is_a? Class
      input.to_s.underscore.to_sym
    end
  end
end
