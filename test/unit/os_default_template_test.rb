require 'test_helper'

class OsDefaultTemplateTest < ActiveSupport::TestCase
  should belong_to(:provisioning_template)
  should belong_to(:operatingsystem)
  should belong_to(:template_kind)
  should validate_presence_of(:provisioning_template_id)
  should validate_presence_of(:template_kind_id)
  should validate_uniqueness_of(:template_kind_id).scoped_to(:operatingsystem_id)
end
