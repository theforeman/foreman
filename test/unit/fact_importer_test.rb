require 'test_helper'

class FactImporterTest < ActiveSupport::TestCase
  class CustomImporter < FactImporter; end

  test "default importers" do
    assert_includes FactImporter.importers.keys, 'puppet'
    assert_equal PuppetFactImporter, FactImporter.importer_for(:puppet)
    assert_equal PuppetFactImporter, FactImporter.importer_for('puppet')
    assert_equal PuppetFactImporter, FactImporter.importer_for(:whatever)
    assert_equal PuppetFactImporter, FactImporter.importer_for('whatever')
  end

  context 'when using a custom importer' do
    setup do
      FactImporter.register_fact_importer :custom_importer, CustomImporter
    end

    test ".register_custom_importer" do
      assert_equal CustomImporter, FactImporter.importer_for(:custom_importer)
    end

    test 'importers without authorized_smart_proxy_features return empty set of features' do
      assert_equal [], FactImporter.importer_for(:custom_importer).authorized_smart_proxy_features
    end
  end
end
