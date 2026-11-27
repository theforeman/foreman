require 'test_helper'
require 'rake'

class PersonalAccessTokensTest < ActiveSupport::TestCase
  setup do
    Rake.application.rake_require 'tasks/personal_access_tokens'
    Rake::Task.define_task(:environment)
    Rake::Task['personal_access_tokens:purge'].reenable
  end

  test 'purge removes only inactive tokens older than the requested age' do
    active = FactoryBot.create(:personal_access_token)
    recent_revoked = FactoryBot.create(:personal_access_token, :revoked => true)
    old_revoked = FactoryBot.create(:personal_access_token, :revoked => true)
    old_expired = FactoryBot.create(:personal_access_token)
    old_revoked.update_column(:updated_at, 31.days.ago)
    old_expired.update_column(:expires_at, 31.days.ago)

    stdout, _stderr = capture_io do
      Rake.application.invoke_task 'personal_access_tokens:purge[30]'
    end

    token_ids = [active, recent_revoked, old_revoked, old_expired].map(&:id)
    assert_equal [active.id, recent_revoked.id].sort, PersonalAccessToken.where(:id => token_ids).pluck(:id).sort
    assert_match /Deleted 2 inactive Personal Access Tokens/, stdout
  end
end
