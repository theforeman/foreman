# The audit class is part of audited plugin
# we reopen here to add search functionality
require 'audited'
require 'audit_extensions'

Audit = Audited.audit_class
Audit.send(:include, AuditExtensions)

module Foreman
  module DisableAudited
    extend ActiveSupport::Concern

    included do
      def self.audited(*args)
        super
        self.auditing_enabled = false if Foreman.in_rake?('db:migrate')
      end
    end
  end
end

::ActiveRecord::Base.send :include, Foreman::DisableAudited
