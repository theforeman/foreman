require "test_helper"

class ClassificationTest < ActiveSupport::TestCase

  #TODO: add more tests here
  def setup
    @classification = Classification.new(:host => hosts(:one))
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
  private

  attr_reader :classification

end
