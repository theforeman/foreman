require 'test_helper'

class TemplatesRenderingStatusCombinationTest < ActiveSupport::TestCase
  describe '#to_status' do
    setup do
      Setting[:safemode_render] = false
    end

    subject do
      FactoryBot.build_stubbed(
        :templates_rendering_status_combination,
        template: FactoryBot.build_stubbed(:provisioning_template, template: template)
      ).to_status
    end

    describe 'unsafemode error' do
      let(:expected) { HostStatus::TemplatesRenderingStatus::UNSAFEMODE_ERRORS }
      let(:template) { '<% invalid_macro %>' }

      it { assert_equal expected, subject }

      context 'with snippet' do
        let(:template) { "<%= snippet('#{snippet.name}') %>" }
        let(:snippet) { FactoryBot.create(:provisioning_template, :snippet, template: '<% invalid_macro %>') }

        it { assert_equal expected, subject }
      end
    end

    describe 'safemode error' do
      let(:expected) { HostStatus::TemplatesRenderingStatus::SAFEMODE_ERRORS }
      let(:template) { '<% @host.owner_name %>' }

      it { assert_equal expected, subject }

      context 'with snippet' do
        let(:template) { "<%= snippet('#{snippet.name}') %>" }
        let(:snippet) { FactoryBot.create(:provisioning_template, :snippet, template: '<% @host.owner_name %>') }

        it { assert_equal expected, subject }
      end
    end

    describe 'ok' do
      let(:expected) { HostStatus::TemplatesRenderingStatus::OK }
      let(:template) { '<% @host.name %>' }

      it { assert_equal expected, subject }

      context 'with snippet' do
        let(:template) { "<%= snippet('#{snippet.name}') %>" }
        let(:snippet) { FactoryBot.create(:provisioning_template, :snippet, template: '<% @host.name %>') }

        it { assert_equal expected, subject }
      end
    end
  end
end
