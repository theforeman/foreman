module Hostext
  module Taxonomies
    extend ActiveSupport::Concern

    included do
      if SETTINGS[:organizations_enabled]
        validates :organization_id, :presence => true, :if => ->(host) { host.managed? }
      end
      if SETTINGS[:locations_enabled]
        validates :location_id, :presence => true, :if => ->(host) { host.managed? }
      end

      after_validation :fix_hostgroup_mismatches, :if => ->(host) { host.hostgroup_id.present? }
    end

    def fix_hostgroup_mismatches
      Taxonomy.enabled_taxonomies.each do |taxonomy|
        host_taxonomy = public_send(taxonomy.singularize.to_sym)
        next if host_taxonomy.blank?
        TaxableTaxonomy.where(
          :taxonomy_id  => host_taxonomy.id,
          :taxable_id   => hostgroup_id,
          :taxable_type => 'Hostgroup'
        ).first_or_create
      end
    end
  end
end
