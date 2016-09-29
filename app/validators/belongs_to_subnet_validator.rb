class BelongsToSubnetValidator < ActiveModel::EachValidator
  def initialize(args)
    @options = args
    super
  end

  def validate_each(record, attribute, value)
    subnet = record.public_send(@options[:subnet] || :subnet)
    return if subnet.nil? || value.nil?
    unless subnet.contains? value
      record.errors.add(attribute, _("does not match selected subnet"))
    end
  rescue
    # probably an invalid ip / subnet were entered
    # we let other validations handle that
  end
end
