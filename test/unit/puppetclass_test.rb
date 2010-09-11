require 'test_helper'

class PuppetclassTest < ActiveSupport::TestCase
  test "name can't be blank" do
    puppet_class = Puppetclass.new
    assert !puppet_class.save
  end

  test "name can't contain trailing white spaces" do
    puppet_class = Puppetclass.new :name => "   test     class   "
    assert !puppet_class.name.strip.squeeze(" ").empty?
    assert !puppet_class.save

    puppet_class.name.strip!.squeeze!(" ")
    assert puppet_class.save
  end

  test "name must be unique" do
    puppet_class = Puppetclass.new :name => "test class"
    assert puppet_class.save

    other_puppet_class = Puppetclass.new :name => "test class"
    assert !other_puppet_class.save
  end

  test "scanForClasses should retrieve puppetclasses from .pp files" do
    path = "/some/path"
    puppet_classes = ["class some_puppet_class {","class other_puppet_class{","class yet_another_puppet_class{"]
    mock(Dir).glob("#{path}/*/manifests/**/*.pp") { puppet_classes }
    puppet_classes.each do |puppet_class|
      mock(File).read(anything) { StringIO.new(puppet_class) }
    end

    klasses = Puppetclass.scanForClasses path
    assert klasses[0] == "some_puppet_class"
    assert klasses[1] == "other_puppet_class"
    assert klasses[2] == "yet_another_puppet_class"
  end
end
