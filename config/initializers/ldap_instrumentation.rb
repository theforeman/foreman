# Debug logging from net-ldap and ldap_fluff events sent via ActiveSupport::Notifications
module Foreman
  class NetLdapSubscriber < ActiveSupport::LogSubscriber
    def self.define_log(action, log_name)
      define_method(action) do |event|
        return unless logger.debug?
        name = '%s (%.1fms)' % [log_name, event.duration]
        debug "  #{color(name, YELLOW, true)}  [ #{yield(event.payload)} ]"
      end
    end

    define_log(:bind, 'LDAP-op bind') { |payload| "result=#{payload[:bind].status}" }
    define_log(:search, 'LDAP-op search') { |payload| "filter=#{payload[:filter]}, base=#{payload[:base]}" }
  end

  class LdapFluffSubscriber < ActiveSupport::LogSubscriber
    def self.define_log(action, log_name)
      define_method(action) do |event|
        return unless logger.debug?
        name = '%s (%.1fms)' % [log_name, event.duration]
        debug "  #{color(name, GREEN, true)}  [ #{yield(event.payload)} ]"
      end
    end

    define_log(:authenticate, 'LDAP authenticate') { |payload| "user=#{payload[:uid]}" }
    define_log(:test, 'LDAP test') {}
    define_log(:user_list, 'LDAP user_list') { |payload| "group=#{payload[:gid]}" }
    define_log(:valid_group?, 'LDAP valid_group?') { |payload| "group=#{payload[:gid]}" }
    define_log(:find_group, 'LDAP find_group') { |payload| "group=#{payload[:gid]}" }
    define_log(:group_list, 'LDAP group_list') { |payload| "user=#{payload[:uid]}" }
    define_log(:valid_user?, 'LDAP valid_user?') { |payload| "user=#{payload[:uid]}" }
    define_log(:find_user, 'LDAP find_user') { |payload| "user=#{payload[:uid]}" }
    define_log(:is_in_groups?, 'LDAP is_in_groups?') { |payload| "user=#{payload[:uid]}, grouplist=#{payload[:grouplist].inspect}" }
  end
end

Foreman::NetLdapSubscriber.attach_to :net_ldap
Foreman::LdapFluffSubscriber.attach_to :ldap_fluff
