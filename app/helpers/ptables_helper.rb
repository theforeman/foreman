module PtablesHelper
  def lookup_family(value)
    names = Operatingsystem.families_as_collection
    names.find { |k| k.value == value }.try(:name)
  end
end
