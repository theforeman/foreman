class TaxableTaxonomy < ActiveRecord::Base
  belongs_to :taxonomy
  belongs_to :taxable, :polymorphic => true

  validates :taxonomy_id, :uniqueness => {:scope => [:taxable_id, :taxable_type]}

  scope :without, lambda{ |types|
    if types.empty?
      where({})
    else
      where(["taxable_taxonomies.taxable_type NOT IN (?)",types])
    end
  }
end
