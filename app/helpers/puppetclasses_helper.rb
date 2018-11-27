module PuppetclassesHelper
  include PuppetclassesAndEnvironmentsHelper
  include LookupKeysHelper

  def overridden?(puppetclass)
    puppetclass.class_params.present? && puppetclass.class_params.map(&:override).all?
  end

  def puppetclass_group_with_icon(puppet_class, puppet_classes, selected)
    css_options = if (puppet_classes - selected).empty?
                    { :class => 'hide' }
                  else
                    {}
                  end
    link_to_function(icon_text('plus', puppet_class, css_options),
                     "expandClassList($(this), '#pc_#{puppet_class}')")
  end
end
