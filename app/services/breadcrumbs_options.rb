class BreadcrumbsOptions
  # TODO: extract URL handing from menu/item and use it here too
  include Rails.application.routes.url_helpers

  def initialize(page_header, controller, action_name, options = {})
    @page_header = page_header
    @controller = controller
    @action_name = action_name
    @options = options
  end

  def bar_props
    {
      isSwitchable: switchable?,
      breadcrumbItems: items,
      resource: resource,
    }
  end

  private

  delegate :logger, :to => :Rails
  delegate :resource_name, :resource_class, :controller_path, :resource_path, :to => :controller
  attr_reader :controller, :action_name, :page_header, :options
  def index_item
    begin
      class_name = resource_class.to_s
    rescue
      class_name = ''
    end

    {
      caption: _(Menu::Manager.get_resource_caption(controller.controller_name.to_s.downcase.pluralize.to_sym)),
      url: resource_path(class_name) || resource_path(resource_name),
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
    if respond_to?(resource_name + '_path')
      resource_path = try(resource_name + '_path', :id => ':id')
    else
      resource_path = "/#{controller_path}/:id"
    end
    (action_name == 'show') ? resource_path : "#{resource_path}/#{action_name}"
  end

  def model_name_field
    resource_class.try(:title_name)
  rescue => err
    # TODO: better handling for plugin detection
    logger.warn("unable to detect breadcrumb title name in for #{controller_path}, defaulting to name")
    logger.debug(err)
    "name"
  end

  def resource
    return unless switchable?
    {
      switcherItemUrl: options[:switcher_item_url] || switcher_url_template,
      resourceUrl: options[:resource_url] || "/api/v2/#{controller_path}",
      nameField: options[:name_field] || model_name_field || 'name',
      resourceFilter: options[:resource_filter] || '',
    }
  end
end
