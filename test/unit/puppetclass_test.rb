require 'test_helper'

class PuppetclassTest < ActiveSupport::TestCase
  test "name can't be blank" do
    puppet_class = Puppetclass.new
    assert !puppet_class.save
  end

  test "name can't contain trailing whitespaces" do
    puppet_class = Puppetclass.new :name => "   test class   "
    assert !puppet_class.name.strip.empty?
    assert !puppet_class.save

    puppet_class.name.strip!
    assert puppet_class.save
  end
end
