require 'test_helper'

class DatabaseSourceTest < ActiveSupport::TestCase
  setup do
    @template = FactoryBot.create(:provisioning_template)
    @subject = Foreman::Renderer::Source::Database.new(@template)
  end

  describe '#content' do
    test 'should return template content' do
      assert_equal @subject.content, @template.template
    end
  end
end
