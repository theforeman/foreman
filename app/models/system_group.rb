  class SystemGroup < Hostgroup
    self.table_name = :hostgroups
    self.inheritance_column = :_type_disabled
  end
