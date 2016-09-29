require 'test_helper'

class ConfigReportImporterTest < ActiveSupport::TestCase
  test 'it should import reports with no metrics' do
    r = ConfigReportImporter.import(read_json_fixture('reports/empty.json'))
    assert r
    assert_equal({}, r.metrics)
  end
end
