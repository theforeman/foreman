class CalcExistingReports < ActiveRecord::Migration[4.2]
  def up
    if (rc = Report.count) > 0
      Report.reset_column_information
      say_with_time "updating Reports records - this may take a long time.. we have #{rc} reports to process hold on" do
        Report.find_each do |r|
          r.update_single_attribute(:status, Report.calc_status(Report.metrics_to_hash(r.log)))
        rescue => e
          say "#{r.id}: #{e} - ignoring this report"
        end
      end
    end
  end

  def down
  end
end
