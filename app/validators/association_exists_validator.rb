class AssociationExistsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if record.send("#{attribute}_id".to_sym).present? && value.nil?
      record.errors.add(attribute, (options[:message] || _("with given ID not found")))
    end
  end
end
