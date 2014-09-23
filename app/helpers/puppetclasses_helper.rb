module PuppetclassesHelper
  include PuppetclassesAndEnvironmentsHelper
  include LookupKeysHelper
  def rdoc_classes_path environment, name
    klass = name.gsub('::', '/')
    "puppet/rdoc/#{environment}/classes/#{klass}.html"
  end
  def is_overriden puppetclass
    if puppetclass.class_params.empty?
      return false
    end
    puppetclass.class_params.each do |param|
      if param[:override] == false
        return false
      end
    end
    return true
  end
end
