object @audit

extends "api/v2/audits/base"

attributes :user_id, :user_type, :user_name, :version, :comment, :associated_id, :associated_type,
           :remote_address, :associated_name, :created_at, :updated_at
