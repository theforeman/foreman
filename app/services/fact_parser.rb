class FactParser
  def self.parser_for(type)
    parsers[type.to_s] || parsers[:puppet]
  end

  def self.parsers
    @parsers ||= { :puppet => PuppetFactParser }.with_indifferent_access
  end

  def self.register_fact_importer(key, klass)
    parsers[key.to_sym] = klass
  end

  attr_reader :facts

  def initialize(facts)
    @facts = HashWithIndifferentAccess.new(facts)
  end

  def operatingsystem
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def environment
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def architecture
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def model
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def domain
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def primary_interface
    raise NotImplementedError, not_implemented_error(__method__)
  end

  EXCLUDED_INTERFACES = /^lo|^usb|^vnet/ unless defined?(EXCLUDED_INTERFACES)

  def interfaces
    raise NotImplementedError, not_implemented_error(__method__)
  end

  # TODO: Remove these method once interfaces management is enabled
  def mac
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def ip
    raise NotImplementedError, not_implemented_error(__method__)
  end

  def certname
    raise NotImplementedError, not_implemented_error(__method__)
  end

  private

  def not_implemented_error(method)
    "#{method} fact parsing not implemented in #{self.class}"
  end

  def is_numeric?(string)
    begin
      !!Integer(string)
    rescue ArgumentError, TypeError
      false
    end
  end
end
