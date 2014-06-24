class TaxHost

  FOREIGN_KEYS = [:location_id, :organization_id, :hostgroup_id,
                  :environment_id, :domain_id, :medium_id,
                  :subnet_id, :compute_resource_id, :realm_id]

  HASH_KEYS = [:location_ids, :organization_ids, :hostgroup_ids,
               :environment_ids, :domain_ids, :medium_ids,
               :subnet_ids, :compute_resource_ids,
               :smart_proxy_ids, :user_ids, :config_template_ids,
               :realm_ids]

  def initialize(taxonomy, hosts=nil)
    @taxonomy = taxonomy
    @hosts    = hosts.nil? ? @taxonomy.hosts : Host.where(:id => Array.wrap(hosts).map(&:id))
  end

  attr_reader :taxonomy, :hosts

  # returns a hash of HASH_KEYS used ids by hosts in a given taxonomy
  def used_ids
    @used_ids = default_ids_hash(populate_values = true)
  end

  def selected_ids
    return @selected_ids if @selected_ids
    ids = default_ids_hash
    #types NOT ignored - get ids that are selected
    taxonomy.taxable_taxonomies.without(taxonomy.ignore_types).group_by { |d| d[:taxable_type] }.map do |k, v|
      ids["#{k.tableize.singularize}_ids"] = v.map { |i| i[:taxable_id] }
    end
    #types that ARE ignored - get ALL ids for object
    Array(taxonomy.ignore_types).each do |taxonomy_type|
      ids["#{taxonomy_type.tableize.singularize}_ids"] = taxonomy_type.constantize.pluck(:id)
    end

    ids["#{opposite_taxonomy_type}_ids"] = Array(taxonomy.send("#{opposite_taxonomy_type}_ids"))
    @selected_ids                        = ids
  end

  def used_and_selected_ids
    @used_and_selected_ids ||= HashWithIndifferentAccess.new(Hash[hash_keys.map do |col|
      if taxonomy.ignore?(hash_key_to_class(col))
        [col, used_ids[col]] # used_ids only if ignore selected
      else
        [col, used_ids[col] & selected_ids[col]] # & operator to intersect COMMON elements of arrays
      end
    end])
  end

  def inherited_ids
    return @inherited_ids if @inherited_ids
    ids = default_ids_hash
    taxonomy.ancestors.each do |t|
      ids = union_deep_hashes(ids, t.selected_ids)
    end
    @inherited_ids = ids
  end

  def selected_or_inherited_ids
    @selected_or_inherited_ids ||= union_deep_hashes(selected_ids, inherited_ids)
  end

  def used_and_selected_or_inherited_ids
    @used_and_selected_or_inherited_ids ||= union_deep_hashes(used_and_selected_ids, inherited_ids)
  end

  def used_or_inherited_ids
    @used_or_inherited_ids = union_deep_hashes(used_ids, inherited_ids)
  end

  def need_to_be_selected_ids
    @need_to_be_selected_ids ||= HashWithIndifferentAccess[hash_keys.map do |col|
      if taxonomy.ignore?(hash_key_to_class(col))
        [col, []] # empty array since nothing needs to be selected
      else
        [col, used_ids[col] - selected_or_inherited_ids[col]] # - operator find NON-common elements of arrays
      end
    end]
  end

  def missing_ids
    return @missing_ids if @missing_ids
    missing_ids = Array.new
    need_to_be_selected_ids.each do |key, values|
      taxable_type = hash_key_to_class(key)
      values.each do |v|
        missing_ids << { :taxonomy_id => taxonomy.id, :taxable_type => taxable_type, :taxable_id => v }
      end
    end
    @missing_ids = missing_ids
  end

  def import_missing_ids
    missing_ids.each do |row|
      # no object for table locations_organizations, so use method *_ids = [array id's] to create relationship
      if %w[Location Organization].include?(row[:taxable_type])
        if (tax = Taxonomy.find_by_id(row[:taxonomy_id]))
          tax.send("#{opposite_taxonomy_type}_ids=".to_sym, [row[:taxable_id]] + tax.send("#{opposite_taxonomy_type}_ids"))
        end
      else
        TaxableTaxonomy.create!(row)
      end
    end
    clear!
  end

  def mismatches
    return @mismatches if @mismatches
    mismatches = Array.new
    need_to_be_selected_ids.each do |key, values|
      taxable_type = hash_key_to_class(key)
      values.each do |v|
        #TODO: use IN (ids) instead of find per id
        taxable_record = taxable_type.constantize.find(v)
        mismatches << { :taxonomy_id   => taxonomy.id,
                        :taxonomy_name => taxonomy.name,
                        :taxonomy_type => taxonomy.class.to_s,
                        :taxable_value => taxable_record.name,
                        :taxable_type  => taxable_type
        }
      end
    end
    @mismatches = mismatches.uniq.compact
  end

  def check_for_orphans
    found_orphan = false
    error_msg = "The following must be selected since they belong to hosts:\n\n"
    need_to_be_selected_ids.each do |key, array_values|
      taxable_type = hash_key_to_class(key)
      unless array_values.empty?
        found_orphan = true
        taxonomy.errors.add(taxable_type.tableize, _("You cannot remove %s that are used by hosts or inherited.") % taxable_type.tableize.humanize.downcase)
      end
    end
    !found_orphan
  end

  def non_inherited_ids(v1 = self.selected_ids, v2 = self.inherited_ids)
    substract_deep_hashes(v1, v2)
  end

  private

  FOREIGN_KEYS.each do |key|
    # def domain_ids
    #   return taxonomy.hosts.pluck(:domain_id)
    # end
    define_method "#{key}s".to_sym do
      #TODO see if distinct pluck makes more sense
      hosts.map(&key).uniq.compact
    end
  end

  # populate used_ids for 3 non-standard_id's
  def user_ids(hosts = self.hosts)
    #TODO: when migrating to rails 3.1+ switch to inner select on users.
    User.unscoped.joins(:direct_hosts).where({ :hosts => { :id => hosts }, :users => { :admin => false } }).pluck('DISTINCT users.id')
  end

  def config_template_ids(hosts = self.hosts)
    ConfigTemplate.template_ids_for(hosts)
  end

  def smart_proxy_ids(hosts = self.hosts)
    SmartProxy.smart_proxy_ids_for(hosts)
  end

  # helpers
  def opposite_taxonomy_type
    if taxonomy.class.to_s == 'Location'
      'organization'
    else
      'location'
    end
  end

  def taxonomy_type
    taxonomy.class.to_s.downcase
  end

  def taxonomy_id_type
    taxonomy_type + "_id"
  end

  def hash_keys
    HASH_KEYS - [taxonomy_id_type.pluralize.to_sym]
  end

  def hash_key_to_class(key)
    key.to_s.gsub(/_ids?$/, '').classify
  end

  def clear!
    @need_to_be_selected_ids = @used_and_selected_ids = @used_ids = @selected_ids = @mismatches = @missing_ids = nil
  end

  def union_deep_hashes(h1, h2)
    h1.merge!(h2) {|k, v1, v2| v1.kind_of?(Array) && v2.kind_of?(Array) ? v1 | v2 : v1 }
  end

  def substract_deep_hashes(h1, h2)
    h1.merge!(h2) do |k, v1, v2|
      if v1.kind_of?(Array) && v2.kind_of?(Array)
        v1.map(&:to_i) - v2.map(&:to_i) - [0]
      else
        v1.map(&:to_i)
      end
    end
  end

  def default_ids_hash(populate_values = false)
    ids = HashWithIndifferentAccess.new
    hash_keys.each do |col|
      ids[col] = populate_values ? Array(self.send(col)) : []
    end
    ids
  end
end
