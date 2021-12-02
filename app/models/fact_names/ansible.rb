# frozen_string_literal: true

module FactNames
  # Define the class that fact names that come from Ansible should have
  # It allows us to filter facts by origin, and also to display the origin
  # in the fact values table (/fact_values)
  class Ansible < FactName
    def origin
      'Ansible'
    end

    def icon_path
      'Ansible.png'
    end
  end
end
