require 'test_helper'

class FactImporterTest < ActiveSupport::TestCase

  test "default importers" do
    assert_includes FactImporter.importers.keys, 'puppet'
    assert_equal PuppetFactImporter, FactImporter.importer_for(:puppet)
    assert_equal PuppetFactImporter, FactImporter.importer_for('puppet')
    assert_equal PuppetFactImporter, FactImporter.importer_for(:whatever)
    assert_equal PuppetFactImporter, FactImporter.importer_for('whatever')
  end

  test ".register_custom_importer" do
    chef_importer = Struct.new(:my_method)
    FactImporter.register_fact_importer :chef, chef_importer

    assert_equal chef_importer, FactImporter.importer_for(:chef)
  end
end
