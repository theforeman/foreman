class Foreman::ImporterPuppetclass
  attr_reader :name, :module, :parameters

  def initialize(opts = { })
    @name = opts["name"] || raise("must provide a puppet class name")
    @module = opts["module"]
    @parameters = opts["params"] || { }
  end

  def to_s
    (name && self.module) ? "#{self.module}::#{name}" : name
  end

  # for now, equality is based on class name, and not on parameters
  def ==(other)
    name == other.name && self.module == other.module
  end

  def parameters?
    @parameters.empty?
  end

  # Auto-detects the best validator type for the given (correctly typed) value.
  # JSON and YAML are better undetected, to prevent the simplest strings to match.
  def self.suggest_key_type(value, default = nil, detect_json_or_yaml = false)
    case value
    when String
      if detect_json_or_yaml
        begin
          return "json" if JSON.load value
        rescue
          return "yaml" if YAML.load value
        end
      end
      "string"
    when TrueClass, FalseClass
      "boolean"
    when Integer
      "integer"
    when Float
      "real"
    when Array
      "array"
    when Hash
      "hash"
    else
      default
    end
  end
end
