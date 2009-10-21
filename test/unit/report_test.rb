require 'test_helper'

class ReportTest < ActiveSupport::TestCase

  test "it should not change host report status when we have skipped reports but there are no log entries" do
    yaml=(File.read(File.expand_path(File.dirname(__FILE__) + "/report-skipped.yml")))
    r=Report.import yaml
    assert r.host.puppet_status == 0
  end

end
