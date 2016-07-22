require 'test_helper'
require 'dynflow/testing'

module Actions
  module Foreman
    module Report
      class ImportTest < ActiveSupport::TestCase
        class DummyReportClass
          def self.import(*args)
          end
        end

        include Dynflow::Testing

        let(:action) do
          create_action(Actions::Foreman::Report::Import)
        end

        let(:planned) do
          plan_action action, {}, DummyReportClass, FactoryGirl.create(:smart_proxy).id
        end

        describe 'importing' do
          it 'calls import on report class' do
            DummyReportClass.expects(:import).returns(OpenStruct.new(:errors => []))
            run_action planned
          end

          it 'raises exception if some error exists' do
            DummyReportClass.expects(:import).returns(OpenStruct.new(:errors => OpenStruct.new(:any? => true, :full_messages => 'custom string')))
            exception = assert_raises(RuntimeError) { run_action planned }
            assert_includes exception.message, 'custom string'
          end
        end
      end
    end
  end
end
