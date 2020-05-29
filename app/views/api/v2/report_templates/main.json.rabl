object @report_template

extends "api/v2/report_templates/base"
extends "api/v2/layouts/permissions"

attributes :description, :snippet, :locked, :vendor, :created_at, :updated_at

node(:available_actions) { |t| { generatable: !t.snippet?, lockable: !t.locked?, unlockable: t.locked? } }
