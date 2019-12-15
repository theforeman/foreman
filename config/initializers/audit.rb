# The audit class is part of audited plugin
# we reopen here to add search functionality
require 'audited'

# Re-opened AuditorInstanceMethods to audit 1-0-* associations
Audited::Auditor::AuditedInstanceMethods.prepend AuditAssociations::AssociationsChanges

# Audit includes Taxonomix which already relies on DSL provided by audited gem
Audit = Audited::Audit
