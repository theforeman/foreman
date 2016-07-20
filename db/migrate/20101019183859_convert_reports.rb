class ConvertReports < ActiveRecord::Migration[4.2]
  def up
    say "About to convert all of the #{Report.count} reports log field into a more DB optimized way... this might take a while....."

    Report.find_in_batches do |reports|
      reports.each do |report|
        case report.log.class.to_s
        when "Puppet::Transaction::Report"
          log = report.log
        when "String"
          log = YAML.load(report.log)
        else
          # this report might have been processed already, skipping
          next
        end

        # Is this a pre 2.6.x report format?
        pre26 = !report.instance_variables.include?("@resource_statuses")

        # Recalcuate the status field if this report is from a 2.6.x puppet client
        report.status = Report.calc_status(Report.metrics_to_hash(log)) unless pre26
        report.metrics = Report.m2h(log.metrics).with_indifferent_access

        report.import_log_messages(log)
        report.log = "" # not really needed, but this way the db can reuse some space instead of claim new one.

        report.save
      end
    end
    remove_column :reports, :log
  end

  def down
    add_column :reports, :log, :text
    say "cant recreate the data, import it again"
  end
end
