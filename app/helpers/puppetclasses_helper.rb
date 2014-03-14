module PuppetclassesHelper
  include PuppetclassesAndEnvironmentsHelper
  include LookupKeysHelper
  def rdoc_classes_path environment, name
    klass = name.gsub('::', '/')
    "puppet/rdoc/#{environment}/classes/#{klass}.html"
  end
end
