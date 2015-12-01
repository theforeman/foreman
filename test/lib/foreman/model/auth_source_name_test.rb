require 'test_helper'

class AuthSourceNameTest < ActiveSupport::TestCase
    def setup
    User.current = users(:admin)
    end

    test "auth_source should not allow 'Internal' or 'Hidden' as names for ldap and external auths" do
        record = AuthSourceLdap.create(:name => "Internal")
        assert_not record.valid?
        assert record.errors[:name].include?(_("Internal is a reserved name."))

        record = AuthSourceLdap.create(:name => "Hidden")
        assert_not record.valid?
        assert record.errors[:name].include?(_("Hidden is a reserved name."))

        record = AuthSourceExternal.create(:name => "Internal")
        assert_not record.valid?
        assert record.errors[:name].include?(_("Internal is a reserved name."))

        record = AuthSourceExternal.create(:name => "Hidden")
        assert_not record.valid?
        assert record.errors[:name].include?(_("Hidden is a reserved name."))
    end
end