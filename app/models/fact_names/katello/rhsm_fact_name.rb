module Katello
  class RhsmFactName < ::FactName
    FACT_TYPE = :rhsm

    def set_name
      self.short_name = name.split(SEPARATOR).last
    end

    def origin
      'RHSM'
    end

    def icon_path
      "icons16x16/redhat.png"
    end
  end
end
