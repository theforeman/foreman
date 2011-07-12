ActiveRecord::Associations::HasManyThroughAssociation.class_eval do
  def delete_records(records)
    klass = @reflection.through_reflection.klass
    records.each do |associate|
      klass.destroy_all(construct_join_attributes(associate))
    end
  end
end
