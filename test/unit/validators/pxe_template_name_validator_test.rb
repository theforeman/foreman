require 'test_helper'

class PxeTemplateNameValidatorTest < ActiveSupport::TestCase
  setup do
    class Validatable
      include ActiveModel::Validations
      validates :value, :pxe_template_name => true
      attr_accessor :value, :name
    end
    @item = Validatable.new
    @item.name = "global_PXELinux"
  end

  test "should be valid when empty" do
    assert @item.valid?
  end

  test "should not be valid when template does not exist" do
    @item.value = "nonexisting template"
    refute @item.valid?
  end

  test "should be valid when template exists" do
    template = TemplateKind.find_by(:name => "PXELinux").provisioning_templates.first
    @item.value = template.name
    assert @item.valid?
  end
end
