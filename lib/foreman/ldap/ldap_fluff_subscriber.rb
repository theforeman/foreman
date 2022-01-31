module Foreman
  module Ldap
    class LdapFluffSubscriber < Foreman::Ldap::LdapSubscriber
      define_log(:authenticate, 'authenticate', GREEN) { |payload| "user=#{payload[:uid]}" }
      define_log(:test, 'test', GREEN) {}
      define_log(:user_list, 'user_list', GREEN) { |payload| "group=#{payload[:gid]}" }
      define_log(:valid_group?, 'valid_group?', GREEN) { |payload| "group=#{payload[:gid]}" }
      define_log(:find_group, 'find_group', GREEN) { |payload| "group=#{payload[:gid]}" }
      define_log(:group_list, 'group_list', GREEN) { |payload| "user=#{payload[:uid]}" }
      define_log(:valid_user?, 'valid_user?', GREEN) { |payload| "user=#{payload[:uid]}" }
      define_log(:find_user, 'find_user', GREEN) { |payload| "user=#{payload[:uid]}" }
      define_log(:is_in_groups?, 'is_in_groups?', GREEN) { |payload| "user=#{payload[:uid]}, grouplist=#{payload[:grouplist].inspect}" }
    end
  end
end
