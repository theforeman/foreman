require 'test_helper'

class HelpersTest < ActiveSupport::TestCase
  let(:scope) { Class.new.include(Foreman::Renderer::Scope::Macros::Helpers).new }

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
end
