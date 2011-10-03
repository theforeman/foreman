module PuppetclassesHelper
  include PuppetclassesAndEnvironmentsHelper
  include LookupKeysHelper
  def rdoc_classes_path environment, name
    klass = name.gsub('::', '/')
    frame  = '<div id="puppetdoc"><iframe src="' + h(root_url + "puppet/rdoc/#{environment}/classes/#{klass}.html") + '" frameborder="0" height="600px" width="100%" scrolling="auto"></iframe></div>'
    update_page do |page|
      page.replace_html(:content, frame)
      page.insert_html(:after, "puppetdoc",link_to(:back))
    end
  end

  def host_counter klass
    # workaround for sqlite bug
    # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4544-rails3-activerecord-sqlite3-lost-column-type-when-using-views#ticket-4544-2
    @counter[klass.id.to_s] || @counter[klass.id.to_i] || 0
  rescue
    "N/A"
  end
end
