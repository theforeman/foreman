# Create notification blueprints prior to tests
module FactImporterIsolation
  extend ActiveSupport::Concern

  def allow_transactions_for(importer)
    importer.stubs(:ensure_no_active_transaction).returns(true)
  end

  module ClassMethods
    def allow_transactions_for_any_importer
      FactImporter.singleton_class.prepend FactImporterFactoryStubber

      FactImporter.register_instance_stubs do |importer_class|
        importer_class.any_instance.stubs(:ensure_no_active_transaction).returns(true)
      end
    end
  end
end

module FactImporterFactoryStubber
  def register_instance_stubs(&block)
    instance_stubs << block
  end

  def importer_for(*args)
    instance = super
    instance_stubs.each do |stub_block|
      stub_block.call(instance)
    end
    instance
  end

  def instance_stubs
    @instance_stubs ||= []
  end
end
