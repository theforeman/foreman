require 'test_helper'

class MediumTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
    disable_orchestration
  end

  should validate_uniqueness_of(:name)
  should allow_values(*valid_name_list).for(:name)
  should_not allow_values(*invalid_name_list).for(:name)

  test "name strips leading and trailing white spaces" do
    medium = Medium.new :name => "   Archlinux mirror   thing   ", :path => "http://www.google.com"
    assert medium.save
    refute medium.name.starts_with?(' ')
    refute medium.name.ends_with?(' ')
  end

  test "should create with valid os family" do
    Operatingsystem.families.each do |family|
      medium = FactoryBot.build(:medium, :os_family => family)
      assert medium.valid?, "Can't create medium with valid os family #{family}"
    end
  end

  test 'should update with multiple valid names' do
    medium = media(:one)
    valid_name_list.each do |name|
      medium.name = name
      assert medium.valid?, "Can't update medium with valid name #{name}"
    end
  end

  test 'should update with multiple os families' do
    medium = media(:one)
    Operatingsystem.families.each do |family|
      medium.os_family = family
      assert medium.valid?, "Can't update medium with valid os family #{family}"
    end
  end

  test 'should not update with multiple invalid names' do
    medium = media(:one)
    invalid_name_list.each do |name|
      medium.name = name
      refute medium.valid?, "Can update medium with invalid name #{name}"
      assert_includes medium.errors.attribute_names, :name
    end
  end

  context 'path validations' do
    setup do
      @medium = FactoryBot.build(:medium)
    end

    test "can't be blank" do
      @medium.path = '  '
      assert @medium.path.strip.empty?
      refute_valid @medium
    end

    test 'must be unique' do
      @medium.path = 'http://www.google.com'
      assert @medium.save!

      other_medium = FactoryBot.build(:medium, :path => @medium.path)
      refute_valid other_medium
    end
  end

  test "should destroy and nullify host.medium_id if medium is in use but host.build? is false" do
    medium = Medium.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert medium.save!

    host = FactoryBot.create(:host, :with_operatingsystem)
    refute host.build?
    host.medium = medium
    host.operatingsystem.media << medium
    assert host.save!

    medium.hosts << host

    assert medium.destroy
    host.reload
    assert host.medium.nil?
  end

  test "should not destroy if medium has hosts that are in build mode" do
    medium = Medium.new :name => "Archlinux mirror", :path => "http://www.google.com"
    assert medium.save!

    host = FactoryBot.create(:host, :with_operatingsystem, :managed)
    host.build = true
    host.medium = medium
    host.operatingsystem.media << medium
    assert host.save!

    medium.hosts << host

    refute medium.destroy
    host.reload
    assert_equal medium, host.medium
  end

  test "os family can be one of defined os families" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => Operatingsystem.families[0]
    assert medium.valid?
  end

  test "os family can't be anything else than defined os families" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => "unknown"
    assert !medium.valid?
  end

  test "os family can be nil" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => nil
    assert medium.valid?
  end

  test "setting os family to a blank string is valid" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => ""
    assert medium.valid?
  end

  test "blank os family is saved as nil" do
    medium = Medium.new :name => "dummy", :path => "http://hello", :os_family => ""
    assert_nil medium.os_family
  end
end
