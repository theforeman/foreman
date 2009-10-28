class AddStatusToReport < ActiveRecord::Migration
  def self.up
    add_column :reports, :status, :integer
    add_index :reports, :status

    Report.reset_column_information
    say_with_time "updating Reports records - this may take a long time.. we have #{Report.count} reports to process hold on" do
      Report.find_each do |r|
        begin
          r.update_single_attribute(:status, Report.report_status(r.log)) if r.status.nil?
          #say "updated #{r.host.shortname}: #{r.reported_at}"
        rescue Exception => e
          say "#{r.id}: #{e}"
        end
      end
    end
  end

  def self.down
#    remove_index :reports, :status
    remove_column :reports, :status
  end
end
