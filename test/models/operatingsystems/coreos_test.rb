require 'test_helper'

class CoreosTest < ActiveSupport::TestCase
  describe '#mediumpath' do
    test 'generates medium path url' do
      operatingsystem = FactoryBot.create(:coreos)
      architecture = architectures(:x86_64)
      medium = FactoryBot.create(:medium, :coreos)
      mock_entity = OpenStruct.new(
        operatingsystem: operatingsystem,
        architecture: architecture,
        medium: medium
      )

      provider = MediumProviders::Default.new(mock_entity)
      assert_equal 'http://stable.release.core-os.net/amd64-usr/', operatingsystem.mediumpath(provider)
    end
  end
end
