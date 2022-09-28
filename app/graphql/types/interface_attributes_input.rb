module Types
  class InterfaceAttributesInput < BaseInputObject
    argument :type, Types::InterfaceTypeEnum, required: false,
      prepare: ->(value, ctx) { InterfaceTypeMapper.map(value.downcase) }
    argument :name, String, required: false
    argument :mac, String, required: false
    argument :ip, String, required: false
    argument :ip6, String, required: false
    argument :identifier, String, required: false
    argument :primary, Boolean, required: false
    argument :provision, Boolean, required: false
    argument :managed, Boolean, required: false
    argument :attached_to, [String], required: false,
      prepare: ->(value, ctx) { value }
    argument :compute_attributes, Types::RawJson, required: false
  end
end
