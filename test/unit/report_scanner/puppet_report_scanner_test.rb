require 'test_helper'

class PuppetReportScannerTest < ActiveSupport::TestCase
  subject { Foreman::ReportScanner::PuppetReportScanner }

  describe '.identify_origin' do
    it 'returns Puppet if puppet_report' do
      subject.expects(:puppet_report?).returns(true)
      assert_equal 'Puppet', subject.identify_origin({})
    end

    it 'returns nil if not puppet_report' do
      subject.expects(:puppet_report?).returns(false)
      assert_nil subject.identify_origin({})
    end
  end

  describe '.puppet_report' do
    let(:example_puppet_logs) do
      [
        {
          "log" => {
            "sources" => {
              "source" => "/Stage[main]/Foreman_scap_client/Package[rubygem-foreman_scap_client]/ensure",
              "message" => "created",
            },
          },
        },
        {
          "log" => {
            "sources" => {
              "source" => "/Stage[main]/Foreman_scap_client/File[foreman_scap_client]/ensure",
              "message" => "defined content as '{md5}44782af0f20a1d3c5ea5fe19a79c1b6f'",
            },
          },
        },
        {
          "log" => {
            "sources" => {
              "source" => "//scapclient.example.tst/Puppet",
              "message" => "Applied catalog in 11.17 seconds",
            },
          },
        },
      ]
    end

    it 'returns true if the source of the first log is puppet' do
      assert subject.puppet_report?(example_puppet_logs)
    end

    it 'returns false if "Puppet" is not found in the source' do
      example_puppet_logs.last['log']['sources']['source'] = 'AnotherReporting'
      refute subject.puppet_report?(example_puppet_logs)
    end
  end
end
