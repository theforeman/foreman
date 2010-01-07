require 'test_helper'

class PuppetclassTest < ActiveSupport::TestCase
  test "name can't be blank" do
    puppet_class = Puppetclass.new
    assert !puppet_class.save
  end

  test "name can't contain trailing white spaces" do
    puppet_class = Puppetclass.new :name => "   test     class   "
    assert !puppet_class.name.strip.squeeze(" ").tr(' ', '').empty?
    assert !puppet_class.save

    puppet_class.name.strip!.squeeze!(" ").tr!(' ', '')
    assert puppet_class.save
  end

  test "name must be unique" do
    puppet_class = Puppetclass.new :name => "test class"
    assert puppet_class.save!

    other_puppet_class = Puppetclass.new :name => "test class"
    assert !other_puppet_class.save
  end
end
