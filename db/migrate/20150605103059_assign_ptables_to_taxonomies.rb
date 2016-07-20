class AssignPtablesToTaxonomies < ActiveRecord::Migration[4.2]
  def up
    if SETTINGS[:organizations_enabled] || SETTINGS[:locations_enabled]
      Ptable.all.each do |ptable|
        if SETTINGS[:organizations_enabled]
          ptable.organizations = ptable.hosts.map(&:organization).compact.uniq
        end

        if SETTINGS[:locations_enabled]
          ptable.locations = ptable.hosts.map(&:location).compact.uniq
        end
      end
    end
  end

  def down
  end
end
