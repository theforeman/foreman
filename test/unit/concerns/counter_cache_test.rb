require 'test_helper'

# this test uses host and architecture to test that cached counters work as
# expected, this applies to all relations with counter_cache set.
class CounterCacheTest < ActiveSupport::TestCase
  setup do
    @host = FactoryGirl.create(:host)
    @architecture = FactoryGirl.create(:architecture)
  end

  test 'hosts_count should be 0 for new architecture' do
    assert_equal 0, @architecture.hosts_count
  end

  test 'assigning host to architecture updates count' do
    assert_difference "@architecture.hosts_count" do
      @architecture.hosts << @host
      @architecture.save!
      @architecture.reload
    end
  end

  test 'assigning architecture to host updates count' do
    assert_difference "@architecture.hosts_count" do
      @host.architecture = @architecture
      @host.save!
      @architecture.reload
    end
  end

  test 'removing architecture from host updates count' do
    @host.architecture = @architecture
    @host.save!
    @architecture.reload
    assert_equal 1, @architecture.hosts_count
    assert_difference "@architecture.hosts_count", -1 do
      @host.architecture = nil
      @host.save!
      @architecture.reload
    end
  end

  test 'setting architecture_id on host updates count' do
    assert_difference "@architecture.hosts_count" do
      @host.update_attribute(:architecture_id, @architecture.id)
      @architecture.reload
    end
  end

  test 'moving host from one architecture to another should update both counters' do
    @architecture2 = FactoryGirl.create(:architecture)
    @host.architecture = @architecture
    @host.save!
    @architecture.reload
    assert_equal 1, @architecture.hosts_count
    assert_equal 0, @architecture2.hosts_count
    @host.architecture = @architecture2
    @host.save!
    @architecture.reload
    @architecture2.reload
    assert_equal 0, @architecture.hosts_count
    assert_equal 1, @architecture2.hosts_count
  end

  test 'moving host from one architecture to another by id should update both counters' do
    @architecture2 = FactoryGirl.create(:architecture)
    @host.architecture = @architecture
    @host.save!
    @architecture.reload
    assert_equal 1, @architecture.hosts_count
    assert_equal 0, @architecture2.hosts_count
    @host.update_attribute(:architecture_id, @architecture2.id)
    @architecture.reload
    @architecture2.reload
    assert_equal 0, @architecture.hosts_count
    assert_equal 1, @architecture2.hosts_count
  end

  test 'destroying a host updates count' do
    @host.architecture = @architecture
    @host.save!
    @architecture.reload
    assert_difference "@architecture.hosts_count", -1 do
      @host.destroy
      @architecture.reload
    end
  end
end
