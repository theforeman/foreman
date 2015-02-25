require 'test_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  def test_host_should_have_tftp
    if unattended?
      h = FactoryGirl.build(:host, :managed, :with_tftp_orchestration)
      assert h.tftp?
      assert_not_nil h.tftp
    end
  end

  def test_host_should_not_have_tftp
    if unattended?
      h = FactoryGirl.create(:host)
      assert_equal false, h.tftp?
      assert_equal nil, h.tftp
    end
  end

  test 'unmanaged should not call methods after managed?' do
    if unattended?
      h = FactoryGirl.create(:host)
      Nic::Managed.any_instance.expects(:provision?).never
      assert h.valid?
      assert_equal false, h.tftp?
    end
  end

  def test_generate_pxe_template_for_build
    if unattended?
      h = FactoryGirl.create(:host, :build => true,
                             :operatingsystem => operatingsystems(:redhat),
                             :architecture => architectures(:x86_64)
                            )
      Setting[:unattended_url] = "http://ahost.com:3000"

      template = h.send(:generate_pxe_template).split("~")
      expected = File.open(Pathname.new(__FILE__).parent + "pxe_template").readlines.map(&:strip)
      assert_equal template,expected
      assert h.build
    end
  end

  def test_generate_pxe_template_for_localboot
    if unattended?
      h = FactoryGirl.create(:host)
      as_admin { h.update_attribute :operatingsystem, operatingsystems(:centos5_3) }
      assert !h.build

      template = h.send(:generate_pxe_template).split("~")
      expected = File.open(Pathname.new(__FILE__).parent + "pxe_local_template").readlines.map(&:strip)
      assert_equal template,expected
    end
  end
end
