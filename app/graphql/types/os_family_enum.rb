module Types
  class OsFamilyEnum < BaseEnum
    ::Operatingsystem.families_as_collection.each do |family|
      value family.value, description: family.name
    end
  end
end
