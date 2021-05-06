module ForemanSalt
  # Define the class that fact names that come from Salt should have
  # It allows us to filter facts by origin, and also to display the origin
  # in the fact values table (/fact_values)
  class FactName < ::FactName
    def origin
      'Salt'
    end

    def icon_path
      'icons16x16/stub/black-s.png'
    end
  end
end
