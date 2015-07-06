require 'test_helper'

class ReportImporterTest < ActiveSupport::TestCase
  setup do
    ActionMailer::Base.deliveries = []
  end

  test 'json_fixture_loader' do
    assert_kind_of Hash, read_json_fixture('report-empty.json')
  end

  test 'it should import reports with no metrics' do
    r = ConfigReportImporter.import(read_json_fixture('report-empty.json'))
    assert r
    assert_equal({}, r.metrics)
  end

  test 'it should import reports where logs is nil' do
    r = Report.import read_json_fixture('report-no-logs.json')
    assert_empty r.logs
  end
end
