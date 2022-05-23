module Foreman
  module GlobalId
    ID_SEPARATOR = '-'
    VERSION_SEPARATOR = ':'
    DEFAULT_VERSION = 1
    BASE64_FORMAT = %r(\A([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?\Z)

    def self.encode(type_name, object_value, version: DEFAULT_VERSION)
      object_value_str = object_value.to_s
      version_str = "%02d" % version

      if type_name.include?(ID_SEPARATOR)
        raise "encode(#{type_name}, #{object_value_str}) contains reserved characters `#{ID_SEPARATOR}` in the type name"
      end

      Base64.strict_encode64([version_str, [type_name, object_value_str].join(ID_SEPARATOR)].join(VERSION_SEPARATOR))
    end

    def self.decode(node_id)
      raise InvalidGlobalIdException.new(node_id) unless base64_encoded?(node_id)
      decoded = Base64.decode64(node_id)
      version, payload = decoded.split(VERSION_SEPARATOR, 2)
      raise InvalidGlobalIdException.new(node_id) unless version.present? && payload.present?
      type_name, object_value = payload.split(ID_SEPARATOR, 2)
      raise InvalidGlobalIdException.new(node_id) unless type_name.present? && object_value.present?
      [version.to_i, type_name, object_value]
    end

    def self.for(obj)
      type_definition = ForemanGraphqlSchema.resolve_type(nil, obj, nil)
      encode(type_definition.graphql_name, obj.id)
    end

    def self.base64_encoded?(string)
      !!string.match(BASE64_FORMAT)
    end

    class InvalidGlobalIdException < Foreman::Exception
      def initialize(gid)
        super("Invalid Global ID '#{gid}'. Can not decode.")
      end
    end
  end
end
