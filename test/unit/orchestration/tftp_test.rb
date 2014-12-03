require 'test_helper'

class TFTPOrchestrationTest < ActiveSupport::TestCase
  setup :disable_orchestration

  def test_host_should_have_tftp
    if unattended?
      h = FactoryGirl.create(:host, :with_operatingsystem, :subnet => subnets(:one))
      as_admin { h.managed = true } # make a trait for this
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

  def test_generate_pxe_template_for_build
    if unattended?
      h = FactoryGirl.create(:host)
      as_admin do
        h.setBuild
        h.update_attribute :operatingsystem, operatingsystems(:redhat)
        h.update_attribute :architecture,    architectures(:x86_64)
      end
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
