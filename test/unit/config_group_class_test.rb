require 'test_helper'

class ConfigGroupClassTest < ActiveSupport::TestCase

  test "combination of config_group and puppetclass must be unique" do
    puppetclass = puppetclasses(:five)
    config_group = config_groups(:one)
    refute ConfigGroupClass.new(:puppetclass_id => puppetclass.id,
                                :config_group_id => config_group.id).valid?
  end


end
