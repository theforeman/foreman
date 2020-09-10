module MediumsHelper
  include PtablesHelper

  def required_nfs_list
    Operatingsystem.families.select { |family| family.constantize.require_nfs_access_to_medium }
  end

  def required_nfs?
    required_nfs_list.include?(@medium.os_family)
  end
end
