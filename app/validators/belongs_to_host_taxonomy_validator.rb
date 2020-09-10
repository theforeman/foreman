class BelongsToHostTaxonomyValidator < ActiveModel::EachValidator
  def initialize(args)
    @options = args
    super
  end

  def validate_each(record, attribute, value)
    taxonomy = @options[:taxonomy]
    return unless record.host.present? && value.present?

    host_taxonomy = record.host.public_send(taxonomy)
    return if host_taxonomy.nil?

    host_taxonomy_ids = host_taxonomy.path_ids
    attribute_taxonomy_ids = value.public_send("#{taxonomy}_ids")

    unless (attribute_taxonomy_ids & host_taxonomy_ids).any?
      attribute_name = attribute.to_s.end_with?('_id') ? attribute : "#{attribute}_id"
      record.errors.add(attribute_name, _("is not defined for host's %s") % _(taxonomy))
    end
  end
end
