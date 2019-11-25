require 'test_helper'

class BelongsToHostTaxonomyValidatorTest < ActiveSupport::TestCase
  class Validatable
    include ActiveModel::Validations
    validates :subnet, :belongs_to_host_taxonomy => { :taxonomy => :location }
    attr_accessor :host, :subnet
  end

  it 'passes if host belongs_to child location' do
    parent = FactoryBot.create(:location)
    child = FactoryBot.create(:location)
    child.update(parent_id: parent.id)
    obj = Validatable.new
    obj.host = FactoryBot.build(:host, location: child)
    obj.subnet = FactoryBot.create(:subnet_ipv4, locations: [parent])
    assert obj.valid?
  end
end
