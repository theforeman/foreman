class EnforceNotNullHostComment < ActiveRecord::Migration[6.1]
  def up
    ::Host::Base.where(comment: nil).update_all(comment: '')

    change_column_default :hosts, :comment, ''
    change_column_null :hosts, :comment, false
  end
end
