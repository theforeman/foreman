require "test_helper"

class ClassificationTest < ActiveSupport::TestCase

  #TODO: add more tests here
  def setup
    @classification = Classification::ClassParam.new(:host => hosts(:one))
  end

  test 'it should return puppetclasses' do
    assert classification.send(:puppetclass_ids).map(&:to_i).include?(puppetclasses(:one).id)
  end

  test 'classes should have parameters' do
    assert classification.send(:class_parameters).include?(lookup_keys(:complex))
  end

  test 'enc_should_return_cluster_param' do
    enc = classification.enc
    assert_equal 'secret', enc['base']['cluster']
  end

  test 'enc_should_return_updated_cluster_param' do
    key   = lookup_keys(:complex)
    assert_equal 'organization,location', key.path
    host = hosts(:one)
    assert_equal taxonomies(:location1), host.location
    assert_equal taxonomies(:organization1), host.organization

    value = User.as :admin do
      LookupValue.create! :lookup_key_id => key.id,
                          :match => "organization=#{taxonomies(:organization1)},location=#{taxonomies(:location1)}",
                          :value => 'test'
    end
    enc = classification.enc

    key.reload
    assert_equal value.value, enc['base']['cluster']
  end

  test "#classes is delegated to the host" do
    pc = FactoryGirl.build(:puppetclass)
    host = FactoryGirl.build(:host)
    host.expects(:classes).returns([pc])
    assert_equal [pc], Classification::ClassParam.new(:host => host).classes
  end

  test "#puppetclass_ids is delegated to the host" do
    pc = FactoryGirl.build(:puppetclass)
    host = FactoryGirl.build(:host)
    host.expects(:puppetclass_ids).returns([pc.id])
    assert_equal [pc.id], Classification::ClassParam.new(:host => host).puppetclass_ids
  end

  test "#enc should return hash of class to nil for classes without parameters" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    assert_equal({pc.name => nil}, get_classparam(env, pc).enc)
  end

  test "#enc should not return class parameters where override is false" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :with_parameters, :environments => [env])
    refute pc.class_params.first.override
    assert_equal({pc.name => nil}, get_classparam(env, pc).enc)
  end

  test "#enc should return default value of class parameters without lookup_values" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :puppetclass => pc, :override => true, :default_value => 'test')
    assert_equal({pc.name => {lkey.key => lkey.default_value}}, get_classparam(env, pc).enc)
  end

  test "#enc should return override value of class parameters" do
    env = FactoryGirl.create(:environment)
    pc = FactoryGirl.create(:puppetclass, :environments => [env])
    lkey = FactoryGirl.create(:lookup_key, :as_smart_class_param, :with_override, :puppetclass => pc)
    classparam = get_classparam(env, pc)
    classparam.expects(:attr_to_value).with('comment').returns('override')
    assert_equal({pc.name => {lkey.key => 'overridden value'}}, classparam.enc)
  end

  private

  attr_reader :classification

  def get_classparam(env, classes)
    classification = Classification::ClassParam.new
    classification.expects(:classes).returns(Array.wrap(classes))
    classification.expects(:environment_id).returns(env.id)
    classification.expects(:puppetclass_ids).returns(Array.wrap(classes).map(&:id))
    classification
  end

end
