require 'integration_test_helper'

class PuppetclassLookupKeyIntegrationTest < ActionDispatch::IntegrationTest
  test "index page" do
    assert_index_page(puppetclass_lookup_keys_path,"Smart Class Parameters",false)
  end
end
