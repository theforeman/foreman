module PuppetclassesHelper
  def rdoc_classes_path environment, name
    klass = name.gsub('::', '/')
    frame  = '<iframe src="' + h(root_url + "puppet/rdoc/#{environment}/classes/#{klass}.html") + '" frameborder="0" height="600px" width="100%" scrolling="auto"></iframe>'
    update_page do |page|
      page.replace_html(:content, frame)
    end
  end
end
