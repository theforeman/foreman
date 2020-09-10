require 'test_helper'

class AltlinuxTest < ActiveSupport::TestCase
  let(:operatingsystem) { FactoryBot.create(:altlinux) }
  let(:architecture) { architectures(:x86_64) }
  let(:medium) { FactoryBot.create(:medium, :altlinux) }
  let(:mock_entity) do
    OpenStruct.new(
      operatingsystem: operatingsystem,
      architecture: architecture,
      medium: medium
    )
  end
  let(:medium_provider) { MediumProviders::Default.new(mock_entity) }

  describe '#mediumpath' do
    test 'generates medium path url' do
      assert_equal 'http://example.com/pub/altlinux/8.2', operatingsystem.mediumpath(medium_provider)
    end
  end

  describe '#url_for_boot' do
    test 'generates kernel url' do
      assert_equal 'http://example.com/pub/altlinux/8.2/boot/vmlinuz', operatingsystem.url_for_boot(medium_provider, :kernel)
    end

    test 'generates initrd url' do
      assert_equal 'http://example.com/pub/altlinux/8.2/boot/full.cz', operatingsystem.url_for_boot(medium_provider, :initrd)
    end
  end
end
