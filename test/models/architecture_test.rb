require 'test_helper'

class ArchitectureTest < ActiveSupport::TestCase
  setup do
    User.current = users :admin
  end

  should validate_presence_of(:name)
  should validate_uniqueness_of(:name)
  should allow_values(*valid_name_list).for(:name)
  should_not allow_values(*invalid_name_list).for(:name)

  test "to_s retrieves name" do
    architecture = Architecture.new :name => "i386"
    assert architecture.to_s == architecture.name
  end

  test "should not destroy while using" do
    architecture = Architecture.new :name => "i386"
    assert architecture.save

    host = FactoryBot.create(:host)
    host.architecture = architecture
    host.save(:validate => false)

    assert_not architecture.destroy
  end

  test "should return EFI filename for i386" do
    architecture = Architecture.new :name => "i386"
    assert_equal "ia32", architecture.bootfilename_efi
  end

  test "should return EFI filename for i686" do
    architecture = Architecture.new :name => "i686"
    assert_equal "ia32", architecture.bootfilename_efi
  end

  test "should return EFI filename for x86-64" do
    architecture = Architecture.new :name => "x86-64"
    assert_equal "x64", architecture.bootfilename_efi
  end

  test "should return EFI filename for x86_64" do
    architecture = Architecture.new :name => "x86_64"
    assert_equal "x64", architecture.bootfilename_efi
  end

  test "should return EFI filename for aarch64" do
    architecture = Architecture.new :name => "aarch64"
    assert_equal "aa64", architecture.bootfilename_efi
  end

  test "should return EFI filename for aa64" do
    architecture = Architecture.new :name => "aa64"
    assert_equal "aa64", architecture.bootfilename_efi
  end

  test "should return EFI filename for ppc64" do
    architecture = Architecture.new :name => "ppc64"
    assert_equal "ppc64", architecture.bootfilename_efi
  end

  test "should return EFI filename for ppc64le" do
    architecture = Architecture.new :name => "ppc64le"
    assert_equal "ppc64le", architecture.bootfilename_efi
  end

  test "should return EFI filename for an unknown arch" do
    architecture = Architecture.new :name => "Weird Árchitecturé 88"
    assert_equal "weird-architecture-88", architecture.bootfilename_efi
  end

  test "should return EFI filename for a cracker" do
    architecture = Architecture.new :name => "../../etc/shadow"
    assert_equal "etc-shadow", architecture.bootfilename_efi
  end

  test "update with multi names" do
    architecture = FactoryBot.create(:architecture)
    valid_name_list.each do |new_name|
      architecture.name = new_name
      assert_valid architecture
      assert_equal architecture.name, new_name
    end
  end

  test "should not update with invalid names" do
    architecture = Architecture.first
    invalid_name_list.each do |name|
      architecture.name = name
      refute_valid architecture
      assert_includes architecture.errors.attribute_names, :name
    end
  end

  test "should destroy architecture" do
    architecture = FactoryBot.create(:architecture)
    assert_difference('Architecture.count', -1) do
      architecture.delete
    end
  end
end
