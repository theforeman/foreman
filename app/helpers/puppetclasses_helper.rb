module PuppetclassesHelper
  include PuppetclassesAndEnvironmentsHelper
  include LookupKeysHelper
  def rdoc_classes_path environment, name
    klass = name.gsub('::', '/')
    "puppet/rdoc/#{environment}/classes/#{klass}.html"
  end

  def host_counter klass
    # workaround for sqlite bug
    # https://rails.lighthouseapp.com/projects/8994-ruby-on-rails/tickets/4544-rails3-activerecord-sqlite3-lost-column-type-when-using-views#ticket-4544-2
    @host_counter[klass.id.to_s] || @host_counter[klass.id.to_i] || 0
  rescue
    _("N/A")
  end
end
