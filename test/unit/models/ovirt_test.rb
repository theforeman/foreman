require 'test_helper'

module Models
  class OvirtTest < ActiveSupport::TestCase
    setup do
      User.current = users :admin
    end

    test "#new_volume should respect preallocate flag" do
      ovirt = Foreman::Model::Ovirt.new
      volume = ovirt.new_volume(:preallocate => '1')
      assert_equal 'false', volume.sparse
      assert_equal 'raw', volume.format

      volume = ovirt.new_volume(:preallocate => '0')
      assert_equal 'true', volume.sparse

      volume = ovirt.new_volume
      assert_equal 'true', volume.sparse
    end
  end
end
