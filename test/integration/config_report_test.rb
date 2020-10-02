require 'integration_test_helper'

class ConfigReportIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @report = FactoryBot.create(:report, :old_report)
  end

  test "delete a report redirects to reports index" do
    visit config_report_path(@report)
    first(:link, "Delete").click
    assert_current_path config_reports_path
  end

  test "adrift report displays warning" do
    report = FactoryBot.create(:report, :adrift)
    visit config_report_path(report)
    assert has_content?('Host times seem to be adrift!')
  end

  context "report creation" do
    def raw_data
      @data ||= read_json_fixture('reports/empty.json')
    end

    test "create report successfully" do
      post '/api/v2/config_reports', params: { :config_report => raw_data }, as: :json
      assert_response :success
    end

    test "backwards-compatibility report creation successful" do
      Foreman::Deprecation.stubs(:api_deprecation_warning).with(regexp_matches(%r{report parameter was renamed to config_reports}))
      post '/api/v2/reports', params: { :report => raw_data }, as: :json
      assert_response :success
    end
  end
end
