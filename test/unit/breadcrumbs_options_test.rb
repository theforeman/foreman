require "test_helper"

class BreadcrumbsOptionsTest < ActiveSupport::TestCase
  def setup
    @page_header = "a page"
    @controller_name = "SomePage"
    @action_name = "show"
  end

  test "it should provide default breadcrumb options" do
    options = BreadcrumbsOptions.new(@page_header, @controller_name, @action_name, {})

    assert_equal options.bar_props, {
      isSwitchable: true,
      breadcrumbItems: [
        {
          caption: "Somepage",
          url: nil
        },
        {
          caption: "a page"
        }
      ],
      resource:
      {
        switcherItemUrl: "/SomePage/:id/",
        resourceUrl: "/api/v2/SomePage",
        nameField: "name"
      }
    }
  end

  test "it should provide the given breadcrumbs options" do
    custom_items = [
      {
        caption: "custom page",
        url: nil
      },
      {
        caption: "another custom page"
      }
    ]
    custom_resource_url = "/api/v2/custom_page"
    custom_switcher_item_url = '/customPage/:id'

    options = BreadcrumbsOptions.new(@page_header, @controller_name, @action_name,
                                   { items: custom_items, switcher_item_url: custom_switcher_item_url,
                                     resource_url: custom_resource_url })

    assert_equal options.bar_props, {
      isSwitchable: true,
      breadcrumbItems: custom_items,
      resource:
      {
        switcherItemUrl: custom_switcher_item_url,
        resourceUrl: custom_resource_url,
        nameField: "name"
      }
    }
  end

  test "it should be switchable" do
    options = BreadcrumbsOptions.new(@page_header, @controller_name, 'show', {})
    custom_options = BreadcrumbsOptions.new(@page_header, @controller_name, 'index', { switchable: true})

    assert_equal options.bar_props[:isSwitchable], true
    assert_equal custom_options.bar_props[:isSwitchable], true
  end

  test "it shouldn't be switchable" do
    options = BreadcrumbsOptions.new(@page_header, @controller_name, 'index', {})

    assert_equal options.bar_props[:isSwitchable], false
  end
end
