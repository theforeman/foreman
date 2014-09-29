require 'test_helper'

class ArchitectureOperatingsystemTest < ActiveSupport::TestCase

  test 'when creating a new association, an audit entry needs to be added' do
    as_admin do
      assert_difference('Audit.count') do
        ArchitectureOperatingsystem.create! :architecture => architectures(:x86_64), :operatingsystem => operatingsystems(:suse)
      end
    end
  end

  test "should not add new association if already exists" do
    assert_difference("ArchitectureOperatingsystem.count", 0) do
      os = operatingsystems(:centos5_3)
      arch = architectures(:x86_64)
      arch_os = ArchitectureOperatingsystem.create(:operatingsystem_id => os.id, :architecture_id => arch.id)
      assert arch_os.errors[:operatingsystem_id].include?("has already been taken")
    end
  end

end
