class EnlargeReportStatus < ActiveRecord::Migration[6.0]
  def up
    remove_index :reports, :status

    User.without_auditing do
      Report.unscoped.in_batches(of: 2000, load: false) do |relation|
        relation.pluck(:id, :status).each do |report_id, current_status|
          old_calc = ConfigReportStatusCalculator.new(bit_field: current_status, size: 6)
          new_calc = ConfigReportStatusCalculator.new(counters: old_calc.status, size: 10)
          Report.unscoped.where(id: report_id).update_all(status: new_calc.calculate)
        end
      end
    end
  end

  def down
    add_index :reports, :status

    User.without_auditing do
      Report.unscoped.in_batches(of: 2000, load: false) do |relation|
        relation.pluck(:id, :status).each do |report_id, current_status|
          old_calc = ConfigReportStatusCalculator.new(bit_field: current_status, size: 10)
          new_calc = ConfigReportStatusCalculator.new(counters: old_calc.status, size: 6)
          Report.unscoped.where(id: report_id).update_all(status: new_calc.calculate)
        end
      end
    end
  end
end
