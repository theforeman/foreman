class RemoveDuplicateFactNames < ActiveRecord::Migration
  def up
    unique_names = FactName.group(:name).maximum(:id)
    unique_names.each do |fact_name, fact_name_id|
      duplicates = FactName.where("name=? and id<>?", fact_name, fact_name_id).select(:id)
      ActiveRecord::Base.transaction do
        FactValue.update_all(
            ["fact_name_id=?", fact_name_id],
            ["fact_name_id in (?)", duplicates])
        UserFact.update_all(
            ["fact_name_id=?", fact_name_id],
            ["fact_name_id in (?)", duplicates])
        FactName.delete_all(["id in (?)", duplicates])
      end if duplicates.any?
    end
  end

  def down
  end
end
