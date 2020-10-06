require 'test_helper'

class OperatingsystemsHelperTest < ActionView::TestCase
  include OperatingsystemsHelper

  describe '#icon' do
    let(:custom_operatingsystem) { FactoryBot.create(:operatingsystem, name: 'randomname_without_family') }

    it 'returns path for custom operatingsystem without family' do
      assert_match /^\/images\/icons.*\/stub\/.*png$/, icon(custom_operatingsystem, path: true)
    end
  end
end
