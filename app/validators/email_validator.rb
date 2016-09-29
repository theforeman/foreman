class EmailValidator < ActiveModel::EachValidator
  EMAIL_REGEXP = /\A(([\w!#\$%&\'\*\+\-\/=\?\^`\{\|\}~]+((\.\"[\w!#\$%&\'\*\+\-\/=\?\^`\{\|\}~\"\(\),:;<>@\[\\\] ]+(\.[\w!#\$%&\'\*\+\-\/=\?\^`\{\|\}~\"\(\),:;<>@\[\\\] ]+)*\")*\.[\w!#\$%&\'\*\+\-\/=\?\^`\{\|\}~]+)*)|(\"[\w !#\$%&\'\*\+\-\/=\?\^`\{\|\}~\"\(\),:;<>@\[\\\] ]+(\.[\w !#\$%&\'\*\+\-\/=\?\^`\{\|\}~\"\(\),:;<>@\[\\\] ]+)*\"))
             @[a-z0-9]+((\.[a-z0-9]+)*|(\-[a-z0-9]+)*)*\z/ix
  def validate_each(record, attribute, value)
    return if options[:allow_blank] && value.empty?
    record.errors.add(attribute, _("is too long (maximum is 254 characters)")) if value && value.length > 254
    record.errors.add(attribute, _("is invalid")) unless value && value.match(EMAIL_REGEXP)
  end
end
