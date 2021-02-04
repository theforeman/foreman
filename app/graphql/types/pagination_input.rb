module Types
  class PaginationInput < BaseInputObject
    argument :page, Integer, required: true
    argument :per_page, Integer, required: true
  end
end
