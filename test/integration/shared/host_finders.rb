module HostFinders
  extend ActiveSupport::Concern

  def go_to_interfaces_tab
    # go to New Host page
    assert_new_button(hosts_path, "Create Host", new_host_path)
    # switch to interfaces tab
    page.find(:link, "Interfaces").click
  end

  def add_interface
    page.find(:button, '+ Add Interface').click

    modal = page.find('#interfaceModal')
    modal.find(:button, "Ok").click
  end

  def modal
    page.find('#interfaceModal')
  end

  def table
    page.find("table#interfaceList")
  end

  def assert_interface_change(change, &block)
    table = page.find("table#interfaceList")
    original_interface_count = table.all('tr', :visible => true).count
    yield
    assert_equal original_interface_count + change, table.all('tr', :visible => true).count
  end

  def index_modal
    page.find('#confirmation-modal')
  end

  def multiple_actions_div
    page.find('#submit_multiple')
  end

  def click_on_inherit(attribute)
    find("#host_#{attribute}_id + .input-group-btn .btn").click
  end

  def class_params
    page.find('#inherited_puppetclasses_parameters')
  end
end
