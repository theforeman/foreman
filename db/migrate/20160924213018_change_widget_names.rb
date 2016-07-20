class ChangeWidgetNames < ActiveRecord::Migration[4.2]
  def up
    Widget.where(:name => "Status table").update_all(:name => "Host Configuration Status")
    Widget.where(:name => "Status chart").update_all(:name => "Host Configuration Chart")
    Widget.where(:name => "Report summary").update_all(:name => "Latest Events")
    Widget.where(:name => "Distribution chart").update_all(:name => "Run Distribution Chart")
  end

  def down
    Widget.where(:name => "Host Configuration Status").update_all(:name => "Status table")
    Widget.where(:name => "Host Configuration Chart").update_all(:name => "Status chart")
    Widget.where(:name => "Latest Events").update_all(:name => "Report summary")
    Widget.where(:name => "Run Distribution Chart").update_all(:name => "Distribution chart")
  end
end
