# The audit class is part of audited plugin
# we reopen here to add search functionality
require 'audited'

Audit = Audited::Audit
Audit.send(:include, AuditExtensions)

# Re-opened AuditorInstanceMethods to audit 1-0-* associations
Auditor = Audited::Auditor::AuditedInstanceMethods
Auditor.send(:include, AuditAssociations)

::ActiveRecord::Base.send :include, AuditAssociations::Auditor
