module PuppetclassesHelper
  def rdoc_classes_path environment, name
    root_url + "puppet/rdoc/#{environment}/classes/#{name.gsub("::", "/")}.html"
  end
end
