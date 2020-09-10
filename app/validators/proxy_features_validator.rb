class ProxyFeaturesValidator < ActiveModel::EachValidator
  def initialize(args)
    @options = args
    super
  end

  def validate_each(record, attribute, value)
    if !value && @options[:required]
      record.errors.add("#{attribute}_id", _('was not found'))
    end

    if value && !value.has_feature?(@options[:feature])
      if @options[:message].nil?
        message = _('does not have the %s feature') % @options[:feature]
      else
        message = _(@options[:message])
      end
      record.errors.add("#{attribute}_id", message)
    end
  end
end
