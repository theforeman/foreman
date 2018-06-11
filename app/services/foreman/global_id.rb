module Foreman
  module GlobalId
    ID_SEPARATOR = '-'
    VERSION_SEPARATOR = ':'
    DEFAULT_VERSION = 1

    def self.encode(type_name, object_value, version: DEFAULT_VERSION)
      object_value_str = object_value.to_s
      version_str = "%02d" % version

      if type_name.include?(ID_SEPARATOR)
        raise "encode(#{type_name}, #{object_value_str}) contains reserved characters `#{ID_SEPARATOR}` in the type name"
      end

      Base64.strict_encode64([version_str, [type_name, object_value_str].join(ID_SEPARATOR)].join(VERSION_SEPARATOR))
    end

    def self.decode(node_id)
      decoded = Base64.decode64(node_id)
      version, payload = decoded.split(VERSION_SEPARATOR, 2)
      type_name, object_value = payload.split(ID_SEPARATOR, 2)
      [version.to_i, type_name, object_value]
    end
  end
end
