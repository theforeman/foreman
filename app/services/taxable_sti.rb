class TaxableSti
  def self.join_scopes(scope, taxonomy_ids)
    scope.joins("INNER JOIN taxable_taxonomies
                    ON taxable_taxonomies.taxable_id = #{scope.table_name}.id
                  WHERE taxable_taxonomies.taxonomy_id IN (#{taxonomy_ids.join(',')})").distinct
  end
end
