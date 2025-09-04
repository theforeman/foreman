class ProxyFeaturesValidator < ActiveModel::EachValidator
  def initialize(args)
    @options = args
    super
  end

  def validate_each(record, attribute, value)
    id = record.public_send("#{attribute}_id")
    if !id && @options[:required]
      record.errors.add("#{attribute}_id", _('was not found'))
    end

    # Due to scope being set on the association, it can happen that the id is present but the association is nil
    if (id || value) && !value.try(:has_feature?, @options[:feature])
      if @options[:message].nil?
        message = _('does not have the %s feature') % @options[:feature]
      else
        message = _(@options[:message])
      end
      record.errors.add("#{attribute}_id", message)
    end
  end
end
