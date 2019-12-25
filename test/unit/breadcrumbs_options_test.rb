require "test_helper"

class BreadcrumbsOptionsTest < ActiveSupport::TestCase
  class FakeController
    def resource_class
      String
    end

    def resource_name
      'string'
    end

    def controller_name
      'string'
    end

    def controller_path
      'strings'
    end

    def resource_path(_resource)
      'strings'
    end
  end

  def setup
    @page_header = "a page"
    @controller = FakeController.new
    @action_name = "show"
  end

  test "it should provide default breadcrumb options" do
    options = BreadcrumbsOptions.new(@page_header, @controller, @action_name, {})

    assert_equal options.bar_props, {
      isSwitchable: true,
      breadcrumbItems: [
        {
          caption: "Strings",
          url: 'strings',
        },
        {
          caption: "a page",
        },
      ],
      resource:
      {
        switcherItemUrl: "/strings/:id/",
        resourceUrl: "/api/v2/strings",
        nameField: "name",
        resourceFilter: "",
      },
    }
  end

  test "it should provide the given breadcrumbs options" do
    custom_items = [
      {
        caption: "custom page",
        url: nil,
      },
      {
        caption: "another custom page",
      },
    ]
    custom_resource_url = "/api/v2/custom_page"
    custom_switcher_item_url = '/customPage/:id'

    options = BreadcrumbsOptions.new(@page_header, @controller, @action_name,
      { items: custom_items, switcher_item_url: custom_switcher_item_url,
        resource_url: custom_resource_url })

    assert_equal options.bar_props, {
      isSwitchable: true,
      breadcrumbItems: custom_items,
      resource:
      {
        switcherItemUrl: custom_switcher_item_url,
        resourceUrl: custom_resource_url,
        nameField: "name",
        resourceFilter: "",
      },
    }
  end

  test "it should be switchable" do
    options = BreadcrumbsOptions.new(@page_header, @controller, 'show', {})
    custom_options = BreadcrumbsOptions.new(@page_header, @controller, 'index', { switchable: true})

    assert_equal options.bar_props[:isSwitchable], true
    assert_equal custom_options.bar_props[:isSwitchable], true
  end

  test "it shouldn't be switchable" do
    options = BreadcrumbsOptions.new(@page_header, @controller, 'index', {})

    assert_equal options.bar_props[:isSwitchable], false
  end
end
