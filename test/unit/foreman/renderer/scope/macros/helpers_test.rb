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
end
