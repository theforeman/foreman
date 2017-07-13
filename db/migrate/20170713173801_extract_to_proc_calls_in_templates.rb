class ExtractToProcCallsInTemplates < ActiveRecord::Migration
  def up
    Template.descendants.each do |klass|
      klass.unscoped.all.each do |template|
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
    content.gsub(/<%(.*?)\(?&:([a-zA-Z0-9!?_]+)\)?(.*)%>/, '<%\1{ |item| item.\2 }\3%>')
  end
end
