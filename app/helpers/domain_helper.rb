module DomainHelper
  def fullname_column record
   record.fullname.empty? ? record.to_label : record.fullname
  end
end
