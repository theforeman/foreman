# some associations shouldn't be set or require special handling.
skip_associations = [:associated_audits, :audits, :default_users, :hosts,
                     :location_parameters, :organization_parameters,
                     :taxable_taxonomies, :reports ] + Template.descendants.map {|type| type.to_s.tableize.to_sym}

User.as_anonymous_admin do
  [Location, Organization].select(&:none?).each do |taxonomy|
    taxonomy.without_auditing do
      tax_name = ENV.fetch("SEED_#{taxonomy.to_s.upcase}", "Default #{taxonomy}")
      tax = taxonomy.create!(name: tax_name)
      associations = taxonomy.reflect_on_all_associations.reject do |assoc|
        skip_associations.include?(assoc.name) ||
        assoc.is_a?(ActiveRecord::Reflection::HasOneReflection) ||
            assoc.is_a?(ActiveRecord::Reflection::BelongsToReflection)
      end
      associations.each do |association|
        tax.send("#{association.name}=", association.klass.all)
      end

      # Only default templates are assigned during taxonomy creation
      Template.where(default: false).each do |template|
        template.send("#{taxonomy.to_s.parameterize.pluralize}=", [tax])
      end

      # Mass update when we can
      tax_id = "#{taxonomy.to_s.parameterize}_id"
      Host::Managed.update_all(tax_id => tax.id)
      User.update_all("default_#{tax_id}": tax.id)

      Setting[:"default_#{taxonomy.to_s.parameterize}"] = tax_name
    end
  end
end
