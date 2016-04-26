require 'test_helper'

class FactImporterTest < ActiveSupport::TestCase
  class CustomFactName < FactName; end
  class CustomImporter < FactImporter
    def fact_name_class
      CustomFactName
    end
  end

  test "default importers" do
    assert_includes FactImporter.importers.keys, 'puppet'
    assert_equal PuppetFactImporter, FactImporter.importer_for(:puppet)
    assert_equal PuppetFactImporter, FactImporter.importer_for('puppet')
    assert_equal PuppetFactImporter, FactImporter.importer_for(:whatever)
    assert_equal PuppetFactImporter, FactImporter.importer_for('whatever')
  end

  test 'importer API defines background processing support' do
    assert FactImporter.respond_to?(:support_background)
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

    context 'importing facts' do
      setup do
        disable_orchestration
        User.current = users :admin
        @host = FactoryGirl.create(:host)
      end

      test 'facts of other type do not collide even if they inherit from FactName' do
        assert_nothing_raised do
          custom_import '_timestamp' => '234'
          puppet_import '_timestamp' => '345'
        end
      end
    end
  end

  def custom_import(facts)
    importer = CustomImporter.new(@host, facts)
    importer.import!
  end

  def puppet_import(facts)
    importer = PuppetFactImporter.new(@host, facts)
    importer.import!
  end
end
