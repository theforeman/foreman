class TaxableTaxonomy < ApplicationRecord
  belongs_to :taxonomy
  belongs_to :taxable, :polymorphic => true

  validates :taxonomy_id, :uniqueness => { :scope => [:taxable_id, :taxable_type] }

  # Always store the base type when associated to an STI class as the has_many scope on the target
  # class will always default to searching for its base_class.
  def taxable_type=(class_name)
    super(class_name.constantize.base_class.to_s)
  end
end
