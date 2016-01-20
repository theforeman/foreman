require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  include ApplicationHelper

  def test_generate_link_for
    proxy = FactoryGirl.create(:smart_proxy)
    subnet = FactoryGirl.create(:subnet, name: 'My subnet')
    proxy.subnets = [subnet]
    links = generate_links_for(proxy.subnets)
    assert_equal(link_to(subnet.to_label, subnets_path(:search => "name = \"#{subnet.name}\"")), links)
  end
end
