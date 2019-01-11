# Debug logging from net-ldap and ldap_fluff events sent via ActiveSupport::Notifications
module Foreman
  class LdapSubscriber < ActiveSupport::LogSubscriber
    include Foreman::TelemetryHelper

    def logger
      ::Foreman::Logging.logger('ldap')
    end

    def self.define_log(action, log_name, color)
      define_method(action) do |event|
        telemetry_observe_histogram(:ldap_request_duration, event.duration)
        return unless logger.debug?
        name = '%s (%.1fms)' % [log_name, event.duration]
        debug "  #{color(name, color, true)}  [ #{yield(event.payload)} ]"
      end
    end
  end

  class NetLdapSubscriber < LdapSubscriber
    define_log(:bind, 'op bind', YELLOW) do |payload|
      if payload[:bind].try(:status)
        "result=#{payload[:bind].status}"
      else
        "result=#{payload[:bind]}"
      end
    end
    define_log(:search, 'op search', YELLOW) { |payload| "filter=#{payload[:filter]}, base=#{payload[:base]}" }
  end

  class LdapFluffSubscriber < LdapSubscriber
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

Foreman::NetLdapSubscriber.attach_to :net_ldap
Foreman::LdapFluffSubscriber.attach_to :ldap_fluff
