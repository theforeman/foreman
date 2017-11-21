class MigrateTemplateToParametersMacros < ActiveRecord::Migration[4.2]
  def up
    Template.unscoped.descendants.each do |klass|
      klass.all.each do |template|
        template.template = convert(template.template)
        if template.template_changed?
          # we need to skip validations so we use #update_attributes
          template.update_attribute :template, template.template
        end
      end
    end

    Parameter.descendants.each do |klass|
      klass.all.each do |parameter|
        parameter.value = convert(parameter.value)
        if parameter.value_changed?
          # we need to skip validations so we use #update_attributes
          parameter.update_attribute :value, parameter.value
        end
      end
    end

    LookupKey.descendants.each do |klass|
      klass.all.each do |parameter|
        parameter.default_value = convert(parameter.default_value.to_s)
        if parameter.default_value_changed?
          # we need to skip validations so we use #update_attributes
          parameter.update_attribute :default_value, parameter.value
        end
      end
    end

    LookupValue.all.each do |parameter|
      parameter.value = convert(parameter.value.to_s)
      if parameter.value_changed?
        # we need to skip validations so we use #update_attributes
        parameter.update_attribute :value, parameter.value
      end
    end
  end

  def down
    # audit can be used for reverting unwanted changes
    say "skipping parameters macros migration"
  end

  def convert(content)
    content = content.gsub(/@host\.param_true\?\((.*?)\)/, 'host_param_true?(\1)')
    content = content.gsub(/@host\.param_false\?\((.*?)\)/, 'host_param_false?(\1)')
    content = content.gsub(/@host\.params\[(.*?)\]/, 'host_param(\1)')
    content.gsub(/@host\.info/, 'host_enc')
  end
end
