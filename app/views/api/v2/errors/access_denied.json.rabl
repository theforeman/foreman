object false => :error

node(:message) { _('Access denied') }
node(:details) { locals[:details] }
node(:missing_permissions) { locals[:missing_permissions] }
