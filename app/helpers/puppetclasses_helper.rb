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
end
