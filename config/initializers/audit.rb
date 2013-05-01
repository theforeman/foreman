# The audit class is part of audited plugin
# we reopen here to add search functionality
require 'audited'
require 'audit_extensions'

Audit = Audited.audit_class
Audit.send(:include, AuditExtentions)
