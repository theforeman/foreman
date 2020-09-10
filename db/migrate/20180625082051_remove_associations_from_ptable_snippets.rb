class RemoveAssociationsFromPtableSnippets < ActiveRecord::Migration[5.1]
  def up
    Ptable.unscoped.where(:snippet => true).where.not(:os_family => [nil, ""]).map do |ptable|
      ptable.os_family = nil
      ptable.save!
    end
  end
end
