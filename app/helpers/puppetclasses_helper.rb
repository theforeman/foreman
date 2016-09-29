module PuppetclassesHelper
  include PuppetclassesAndEnvironmentsHelper
  include LookupKeysHelper
  def rdoc_classes_path(environment, name)
    klass = name.gsub('::', '/')
    "puppet/rdoc/#{environment}/classes/#{klass}.html"
  end

  def overridden?(puppetclass)
    puppetclass.class_params.present? && puppetclass.class_params.map(&:override).all?
  end

  def puppetclass_group_with_icon(list, selected)
    css_options = if (list.last - selected).empty?
                    { :class => 'hide' }
                  else
                    {}
                  end
    link_to_function(icon_text('plus', list.first, css_options),
                     "expandClassList($(this), '#pc_#{list.first}')")
  end
end
