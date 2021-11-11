module FactImporters
  class Structured < Base
    include ActionView::Helpers::NumberHelper

    def preload_fact_names
      # Also fetch compose values, generating {NAME => [ID, COMPOSE]}, avoiding loading the entire model
      Hash[fact_name_class.where(:type => fact_name_class).reorder('').pluck(:name, :id, :compose).index_by { |fact| [fact.shift, fact] }]
    end

    def ensure_fact_names
      super

      composite_fact_names = facts.map do |key, value|
        key if value.nil?
      end.compact

      affected_records = fact_name_class.where(:name => composite_fact_names, :compose => false).update_all(:compose => true)

      # reload name records if compose flag was reset.
      initialize_fact_names if affected_records > 0
    end

    def fact_name_attributes(name)
      attributes = super
      fact_value = facts[name]
      parent_fact_record = fact_names[parent_fact_name(name)]

      attributes[:parent] = parent_fact_record
      attributes[:compose] = fact_value.nil?
      attributes
    end

    def parent_fact_name(child_fact_name)
      split = child_fact_name.rindex(FactName::SEPARATOR)
      return nil unless split
      child_fact_name[0, split]
    end

    def normalizer
      return Normalizers::Katello if @type == FactNames::Rhsm::FACT_TYPE
      Normalizers::Structured
    end
  end
end
