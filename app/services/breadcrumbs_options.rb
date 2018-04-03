class BreadcrumbsOptions
  #TODO: extract URL handing from menu/item and use it here too
  include Rails.application.routes.url_helpers

  def initialize(page_header, controller_name, action_name, options = {})
    @page_header = page_header
    @controller_name = controller_name
    @action_name = action_name
    @options = options
  end

  def bar_props
    {
      isSwitchable: switchable?,
      breadcrumbItems: items,
      resource: resource
    }
  end

  private

  delegate :logger, :to => :Rails
  attr_reader :controller_name, :action_name, :page_header, :options
  def index_item
    {
      caption: _(controller_name.humanize),
      url: try("#{controller_name}_path")
    }
  end

  def page_item
    { caption: page_header }
  end

  def items
    return options[:items] if options[:items].is_a?(Array)

    items = []
    items << index_item unless action_name == 'index'
    items << page_item
    items.flatten
  end

  def switchable?
    return options[:switchable] unless options[:switchable].nil?
    ['edit', 'show'].include? action_name
  end

  def switcher_url_template
    actual_action_name = (action_name == 'show') ? '' : action_name
    "/#{controller_name}/:id/#{actual_action_name}"
  end

  def model_name_field
    controller_name.camelize.singularize.try(:constantize).try(:title_name)
  rescue => err
    # TODO: better handling for plugin detection
    logger.warn("unable to detect breadcrumb title name in for #{controller_name}, defaulting to name")
    logger.debug(err)
    "name"
  end

  def resource
    return unless switchable?
    {
      switcherItemUrl: options[:switcher_item_url] || switcher_url_template,
      resourceUrl: options[:resource_url] || "/api/v2/#{controller_name}",
      nameField: options[:name_field] || model_name_field || 'name'
    }
  end
end
