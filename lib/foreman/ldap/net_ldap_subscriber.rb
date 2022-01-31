module Foreman
  module Ldap
    class NetLdapSubscriber < Foreman::Ldap::LdapSubscriber
      define_log(:bind, 'op bind', YELLOW) do |payload|
        if payload[:bind].try(:status)
          "result=#{payload[:bind].status}"
        else
          "result=#{payload[:bind]}"
        end
      end
      define_log(:search, 'op search', YELLOW) { |payload| "filter=#{payload[:filter]}, base=#{payload[:base]}" }
    end
  end
end
