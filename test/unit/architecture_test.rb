require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
    Architecture.all.each do |a| #because we load from fixtures, counters aren't updated
      Architecture.reset_counters(a.id,:hosts)
      Architecture.reset_counters(a.id,:hostgroups)
    end
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should_not allow_value('  ').for(:name)

  test "to_s retrieves name" do
    architecture = Architecture.new :name => "i386"
    assert architecture.to_s == architecture.name
  end

  test "should update hosts_count" do
    arch = architectures(:sparc)
    assert_difference "arch.hosts_count" do
      FactoryGirl.create(:host).update_attribute(:architecture, arch)
      arch.reload
    end
  end

  test "should update hostgroups_count" do
    arch = architectures(:sparc)
    assert_difference "arch.hostgroups_count" do
      hostgroups(:common).update_attribute(:architecture, arch)
      arch.reload
    end
  end

  test "should not destroy while using" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    host = FactoryGirl.create(:host)
    host.architecture = architecture
    host.save(:validate => false)

    assert_not architecture.destroy
  end
end
