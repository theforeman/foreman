require 'test_helper'

class BaseSourceTest < ActiveSupport::TestCase
  setup do
    @template = FactoryBot.create(:provisioning_template)
    @subject = Foreman::Renderer::Source::Base.new(@template)
  end

  describe '#name' do
    test 'should return template name' do
      assert_equal @subject.name, @template.name
    end

    test 'should return template name for unnamed template' do
      @template.update(name: nil)
      assert_equal @subject.name, 'Unnamed'
    end
  end
end
