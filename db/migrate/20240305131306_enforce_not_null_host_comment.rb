class EnforceNotNullHostComment < ActiveRecord::Migration[6.1]
  def up
    ::Host.where(comment: nil).update(comment: '')

    change_column_default :hosts, :comment, ''
    change_column_null :hosts, :comment, false
  end
end
