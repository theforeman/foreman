class AssignPtablesToTaxonomies < ActiveRecord::Migration[4.2]
  def up
    Ptable.all.each do |ptable|
      ptable.organizations = ptable.hosts.map(&:organization).compact.uniq
      ptable.locations = ptable.hosts.map(&:location).compact.uniq
    end
  end

  def down
  end
end
