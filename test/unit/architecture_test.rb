require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
    Architecture.all.each do |a| #because we load from fixtures, counters aren't updated
      Architecture.reset_counters(a.id,:hosts)
      Architecture.reset_counters(a.id,:hostgroups)
    end
  end

  test "should not save without a name" do
    architecture = Architecture.new
    assert_not architecture.save
  end

  test "name should not be blank" do
    architecture = Architecture.new :name => "   "
    assert_empty architecture.name.strip
    assert_not architecture.save
  end

  test "name should not contain white spaces" do
    architecture = Architecture.new :name => " i38  6 "
    assert_not_empty architecture.name.squeeze(" ").tr(' ', '')
    assert_not architecture.save

    architecture.name.squeeze!(" ").tr!(' ', '')
    assert architecture.save
  end

  test "name should be unique" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    other_architecture = Architecture.new :name => "i386"
    assert_not other_architecture.save
  end

  test "to_s retrives name" do
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
