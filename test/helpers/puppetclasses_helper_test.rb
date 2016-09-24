require 'test_helper'

class PuppetclassesHelperTest < ActionView::TestCase
  include PuppetclassesHelper

  describe ".overridden?" do
    setup do
      @env = FactoryGirl.create(:environment)
    end

    it "returns true when all params are overridden" do
      pc = FactoryGirl.create(:puppetclass, :with_parameters, :environments => [@env])
      pc.class_params.first.update_attributes(:override => true)
      assert pc.class_params.first.override
      assert overridden?(pc)
    end

    it "returns false when one parameter isn't overridden" do
      pc = FactoryGirl.create(:puppetclass, :with_parameters, :parameter_count => 2, :environments => [@env])
      pc.class_params.first.update_attributes(:override => true)
      assert pc.class_params.first.override
      refute pc.class_params.last.override
      refute overridden?(pc)
    end

    it "returns false when no parameters" do
      pc = FactoryGirl.create(:puppetclass)
      refute overridden?(pc)
    end
  end
end
