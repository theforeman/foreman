require 'test_helper'
require Rails.root.join('db/migrate/20260917151850_enforce_unique_jwt_secret_per_user.rb')

class EnforceUniqueJwtSecretPerUserTest < ActiveSupport::TestCase
  let(:migration) { EnforceUniqueJwtSecretPerUser.new }

  setup do
    migrate_down if jwt_secret_index_unique? || registration_facet_index_unique?
  end

  context 'jwt_secrets' do
    test 'replaces non-unique index with unique index' do
      refute jwt_secret_index_unique?
      migrate_up
      assert jwt_secret_index_unique?
    end

    test 'rejects duplicate user_id after migration' do
      user = FactoryBot.create(:user)
      user.jwt_secret!
      migrate_up

      assert_raises(ActiveRecord::RecordNotUnique) do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO jwt_secrets (token, user_id, created_at, updated_at) VALUES ('dup_token', #{user.id}, NOW(), NOW())"
        )
      end
    end

    test 'deletes duplicate jwt_secrets keeping the oldest' do
      user = FactoryBot.create(:user)
      oldest = JwtSecret.create!(user_id: user.id)
      newer = JwtSecret.new(user_id: user.id)
      newer.save!(validate: false)

      migrate_up

      assert JwtSecret.exists?(oldest.id)
      refute JwtSecret.exists?(newer.id)
      assert_equal 1, JwtSecret.where(user_id: user.id).count
    end

    test 'leaves non-duplicate jwt_secrets untouched' do
      user1 = FactoryBot.create(:user)
      user2 = FactoryBot.create(:user)
      s1 = user1.jwt_secret!
      s2 = user2.jwt_secret!

      migrate_up

      assert JwtSecret.exists?(s1.id)
      assert JwtSecret.exists?(s2.id)
    end

    test 'jwt_secret! returns existing secret without creating a duplicate' do
      migrate_up
      user = FactoryBot.create(:user)
      first = user.jwt_secret!

      fresh_user = User.find(user.id)
      second = fresh_user.jwt_secret!

      assert_equal first.id, second.id
      assert_equal 1, JwtSecret.where(user_id: user.id).count
    end
  end

  context 'registration_facets' do
    test 'replaces non-unique index with unique index' do
      refute registration_facet_index_unique?
      migrate_up
      assert registration_facet_index_unique?
    end

    test 'rejects duplicate host_id after migration' do
      host = FactoryBot.create(:host, :managed)
      host.registration_facet!
      migrate_up

      assert_raises(ActiveRecord::RecordNotUnique) do
        ActiveRecord::Base.connection.execute(
          "INSERT INTO registration_facets (host_id, jwt_secret, created_at, updated_at) VALUES (#{host.id}, 'dup_secret', NOW(), NOW())"
        )
      end
    end

    test 'deletes duplicate registration_facets keeping the oldest' do
      host = FactoryBot.create(:host, :managed)
      oldest = ForemanRegister::RegistrationFacet.create!(host: host)
      newer = ForemanRegister::RegistrationFacet.new(host: host)
      newer.save!(validate: false)

      migrate_up

      assert ForemanRegister::RegistrationFacet.exists?(oldest.id)
      refute ForemanRegister::RegistrationFacet.exists?(newer.id)
      assert_equal 1, ForemanRegister::RegistrationFacet.where(host_id: host.id).count
    end

    test 'leaves non-duplicate registration_facets untouched' do
      host1 = FactoryBot.create(:host, :managed)
      host2 = FactoryBot.create(:host, :managed)
      f1 = host1.registration_facet!
      f2 = host2.registration_facet!

      migrate_up

      assert ForemanRegister::RegistrationFacet.exists?(f1.id)
      assert ForemanRegister::RegistrationFacet.exists?(f2.id)
    end

    test 'registration_facet! returns existing facet without creating a duplicate' do
      migrate_up
      host = FactoryBot.create(:host, :managed)
      first = host.registration_facet!

      fresh_host = Host::Managed.find(host.id)
      second = fresh_host.registration_facet!

      assert_equal first.id, second.id
      assert_equal 1, ForemanRegister::RegistrationFacet.where(host_id: host.id).count
    end
  end

  context 'down' do
    test 'restores non-unique indexes' do
      migrate_up
      migrate_down

      refute jwt_secret_index_unique?
      refute registration_facet_index_unique?
    end
  end

  private

  def migrate_up
    migration.suppress_messages { migration.up }
  end

  def migrate_down
    migration.suppress_messages { migration.down }
  end

  def jwt_secret_index_unique?
    idx = ActiveRecord::Base.connection.indexes(:jwt_secrets).find { |i| i.name == 'index_jwt_secrets_on_user_id' }
    idx&.unique || false
  end

  def registration_facet_index_unique?
    idx = ActiveRecord::Base.connection.indexes(:registration_facets).find { |i| i.name == 'index_registration_facets_on_host_id' }
    idx&.unique || false
  end
end
