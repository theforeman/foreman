require 'test_helper'

class AuditTest < ActionDispatch::IntegrationTest

  test "index page" do
    assert_index_page(audits_path,"Audits",nil,true)
  end

  test "audit content" do
    visit audits_path
    assert has_content?("updated Host"), "expected 'updated Host' but it doesn't exit"
    assert has_content?("Architecture changed"), "expected 'Architecture changed' but it doesn't exit"
  end

end
