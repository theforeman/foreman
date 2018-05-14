class FixTemplateAuditVersions < ActiveRecord::Migration[5.1]
  def up
    [ ProvisioningTemplate, Ptable].each do |model|
      model.unscoped.each do |object|
        object.audits.order(created_at: :asc).first.update(:version => 1) if object.audits.any?
        object.audits.order(created_at: :asc).each_cons(2) do |prev_audit, curr_audit|
          curr_audit.update(:version => prev_audit.version + 1)
        end
      end
    end
  end

  def down
  end
end
