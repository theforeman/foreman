class BelongsToHostTaxonomyValidator < ActiveModel::EachValidator
  def initialize(args)
    @options = args
    super
  end

  def validate_each(record, attribute, value)
    taxonomy = @options[:taxonomy]
    return unless record.host.present? && value.present?

    host_taxonomy = record.host.public_send(taxonomy)
    attribute_taxonomies = value.public_send(taxonomy.to_s.pluralize.to_sym)

    return if host_taxonomy.nil? && attribute_taxonomies.empty?

    attribute_name = attribute.to_s.end_with?('_id') ? attribute : "#{attribute}_id"
    record.errors.add(attribute_name, _("is not defined for host's %s") % _(taxonomy)) unless include_or_empty?(attribute_taxonomies, host_taxonomy)
  end

  private

  def include_or_empty?(list, item)
    (list.empty? && item.nil?) || list.include?(item)
  end
end
