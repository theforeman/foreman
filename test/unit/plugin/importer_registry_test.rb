require 'test_helper'

class FactImporterRegistry < ActiveSupport::TestCase
  class TestClass
  end

  def test_register
    fact_importer = Foreman::Plugin::FactImporterRegistry.new
    fact_importer.register(:test_class, TestClass, false)
    assert_equal fact_importer.importers[:test_class], "FactImporterRegistry::TestClass"
  end

  def test_register_default
    fact_importer = Foreman::Plugin::FactImporterRegistry.new
    fact_importer.register(:test_class, TestClass, true)
    assert_equal fact_importer.importers[:test_class], "FactImporterRegistry::TestClass"
    assert_equal fact_importer.importers[:random_key], "FactImporterRegistry::TestClass"
  end

  def test_get
    fact_importer = Foreman::Plugin::FactImporterRegistry.new
    fact_importer.register(:test_class, TestClass, false)
    assert_equal fact_importer.get(:test_class), TestClass
  end

  def test_get_default
    fact_importer = Foreman::Plugin::FactImporterRegistry.new
    fact_importer.register(:test_class, TestClass, true)
    assert_equal fact_importer.get(:random_key), TestClass
  end

  def test_fact_features
    fact_importer = Foreman::Plugin::FactImporterRegistry.new
    fact_importer.register(:test_class, TestClass, true)
    FactImporterRegistry::TestClass.expects(:authorized_smart_proxy_features).returns([:test_feature])
    assert_equal :test_feature, fact_importer.fact_features.first
  end
end
