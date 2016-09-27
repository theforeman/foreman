module Classification
  class NonPuppetParam < Base
    delegate :location, :organization, :to => :host

    def enc
      values = values_hash

      parameters = {}
      class_parameters.each do |key|
        parameters[key.to_s] = value_of_key(key, values)
      end
      parameters
    end

    def handle_ancestry(element, match_key)
      if ['hostgroup', 'organization', 'location'].include?(element)
        match_key.split(LookupKey::EQ_DELM).last
      else
        ''
      end
    end

    def location_matches
      @location_matches ||= matches_for_taxonomy(location)
    end

    def organization_matches
      @organization_matches ||= matches_for_taxonomy(organization)
    end

    def matches_for_taxonomy(taxonomy)
      matches = []
      if taxonomy
        path = taxonomy.to_label
        while path.include?("/")
          path = path[0..path.rindex("/")-1]
          matches << "#{taxonomy.class.model_name.to_s.downcase}#{LookupKey::EQ_DELM}#{path}"
        end
      end
      matches
    end

    def path2matches
      matches = []
      possible_value_orders.each do |rule|
        match = Array.wrap(rule).map do |element|
          "#{element}#{LookupKey::EQ_DELM}#{attr_to_value(element)}"
        end
        matches << match.join(LookupKey::KEY_DELM)
        hostgroup_matches.each do |hostgroup_match|
          match[match.index { |m| m =~ /hostgroup\s*=/ }]=hostgroup_match
          matches << match.join(LookupKey::KEY_DELM)
        end if Array.wrap(rule).include?("hostgroup")
        location_matches.each do |location_match|
          match[match.index { |m| m =~ /location\s*=/ }]=location_match
          matches << match.join(LookupKey::KEY_DELM)
        end if Array.wrap(rule).include?("location")
        organization_matches.each do |organization_match|
          match[match.index { |m| m =~ /organization\s*=/ }]=organization_match
          matches << match.join(LookupKey::KEY_DELM)
        end if Array.wrap(rule).include?("organization")
      end
      matches
    end

    def values_hash
      super :include_defaults => true
    end

    protected

    def class_parameters
      @keys ||= GlobalLookupKey.all
    end
  end
end
