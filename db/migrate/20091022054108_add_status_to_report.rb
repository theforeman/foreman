class AddStatusToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :status, :integer
    add_index :reports, :status
    add_index :reports, :host_id
    add_index :reports, :reported_at

    Report.reset_column_information
    say_with_time "updating Reports records - this may take a long time.. we have #{Report.count} reports to process hold on" do
      Report.find_each(:conditions => ["status is ?", nil]) do |r|
        begin
          r.update_single_attribute(:status, Report.report_status(r.log))
        rescue Exception => e
          say "#{r.id}: #{e} - ignoring this report"
        end
      end
    end
  end

  def self.down
    remove_index :reports, :status
    remove_index :reports, :host_id
    remove_index :reports, :reported_at
    remove_column :reports, :status
  end
end
