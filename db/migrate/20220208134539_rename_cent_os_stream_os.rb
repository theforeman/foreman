class RenameCentOsStreamOs < ActiveRecord::Migration[6.0]
  def up
    User.without_auditing do
      # When redhat-lsb-core package is installed, puppet creates
      # description/title "CentOS Stream 8", however, when the package is not
      # present description is unset and title is set to "CentOS_Stream 8" from
      # the OS name and major by the ActiveRecord callback. Let's migrate both
      # cases.
      Operatingsystem.unscoped.where("type = 'Redhat' and name = 'CentOS' and (description like '%CentOS%Stream%' or title like '%CentOS%Stream%')").update_all(name: "CentOS_Stream")
    end
  end

  def down
    User.without_auditing do
      Operatingsystem.unscoped.where("type = 'Redhat' and name = 'CentOS_Stream' and (description like '%CentOS%Stream%' or title like '%CentOS%Stream%')").update_all(name: "CentOS")
    end
  end
end
