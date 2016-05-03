module Foreman::Controller::TaxonomyWarnings
  extend ActiveSupport::Concern

  included do
    before_filter :taxonomy_warnings, :only => [:edit]
  end

  def taxonomy_warnings
    @warnings ||= []

    Taxonomy.enabled_taxonomies.each do |taxonomy|
      @warnings += single_taxonomy_warnings(taxonomy.singularize, @hostgroup)
    end
  end

  private

  def single_taxonomy_warnings(taxonomy, hostgroup)
    warnings = []

    taxonomies_count = hostgroup.hosts.unscoped.distinct.count("#{taxonomy}_id")
    warnings << _('The hostgroup is used by hosts in multiple %s' % taxonomy.pluralize) if taxonomies_count > 1
    warnings
  end
end
