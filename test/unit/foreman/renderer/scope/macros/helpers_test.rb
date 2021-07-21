require 'test_helper'

class HelpersTest < ActiveSupport::TestCase
  class HelpersTestScope
    def initialize(preview)
      @preview = preview
    end

    def preview?
      @preview
    end
  end

  let(:scope) { HelpersTestScope.include(Foreman::Renderer::Scope::Macros::Helpers).new(false) }
  let(:preview_scope) { HelpersTestScope.include(Foreman::Renderer::Scope::Macros::Helpers).new(true) }

  describe '#sequence_hostgroup_param_next' do
    let(:hg) { FactoryBot.create(:hostgroup) }

    it "should default to 1" do
      assert_equal "1", scope.sequence_hostgroup_param_next(hg.title)
    end

    it "preview should not increase" do
      assert_equal "1", scope.sequence_hostgroup_param_next(hg.title)
      assert_equal "2", preview_scope.sequence_hostgroup_param_next(hg.title)
      assert_equal "2", preview_scope.sequence_hostgroup_param_next(hg.title)
    end

    it "should increase by one" do
      assert_equal "1", scope.sequence_hostgroup_param_next(hg.title)
      assert_equal "2", scope.sequence_hostgroup_param_next(hg.title)
      hg.reload
      assert_equal 2, hg.parameters["sequence_num_default"]
    end

    it "should store the counter in a hostgroup parameter" do
      assert_equal "200", scope.sequence_hostgroup_param_next(hg.title, 200)
      hg.reload
      assert_equal 200, hg.parameters["sequence_num_default"]
    end

    it "should store the counter in a hostgroup parameter under a name" do
      assert_equal "200", scope.sequence_hostgroup_param_next(hg.title, 200, "mycounter")
      hg.reload
      assert_equal 200, hg.parameters["sequence_num_mycounter"]
    end

    it "should store the counter with leading zeroes" do
      assert_equal "00003", scope.sequence_hostgroup_param_next(hg.title, 3, "mycounter", 5)
    end

    it "should raise an error on non-existing hostgroup" do
      assert_raises Foreman::Renderer::Errors::HostgroupNotFoundError do
        scope.sequence_hostgroup_param_next('does-not-exist')
      end
    end
  end

  describe '#parse_yaml' do
    let(:data) { "---\nkey: value\n" }
    let(:expected) { { 'key' => 'value' } }

    it { assert_equal expected, scope.parse_yaml(data) }
  end

  describe '#parse_json' do
    let(:data) { "{\"key\":\"value\"}" }
    let(:expected) { { 'key' => 'value' } }

    it { assert_equal expected, scope.parse_json(data) }
  end

  describe '#to_json' do
    let(:data) { { key: "value" } }
    let(:expected) { "{\n  \"key\": \"value\"\n}" }

    it { assert_equal expected, scope.to_json(data) }
  end

  describe '#to_yaml' do
    let(:data) { { key: "value" } }
    let(:expected) { "---\n:key: value\n" }

    it { assert_equal expected, scope.to_yaml(data) }
  end

  describe '#format_time' do
    let(:unix_timestamp) { 1356006012 } # 2012-12-20 12:20:12
    let(:utc_time) { Time.zone.local(2012, 12, 20, 12, 20, 12).utc }
    let(:format_pattern) { '%Y-%-m-%-d %k:%M:%S %z' }

    it { assert_equal utc_time.strftime(format_pattern), scope.format_time(unix_timestamp, format: format_pattern) }
  end

  describe '#shell_escape' do
    string = "how y'all doin?"
    escaped = "how\\ y\\'all\\ doin\\?"

    it { assert_equal escaped, scope.shell_escape(string) }
  end
end
