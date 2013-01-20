class TaxHost

  HASH_KEYS = [:location_ids, :organization_ids, :hostgroup_ids,
                 :environment_ids, :domain_ids, :medium_ids,
                 :subnet_ids, :compute_resource_ids,
                 :smart_proxy_ids, :user_ids, :config_template_ids]

  def initialize(taxonomy=nil, host=nil)
    @taxonomy = taxonomy
    @host = host
  end

  def used_ids(hosts=nil)
    return @used_ids if @used_ids
    hosts ||= @taxonomy.hosts
    a = Hash.new
    HASH_KEYS.each do |col|
      a = a.merge(col => Array.new)
      a[col] = self.send(col,hosts)
    end
    @used_ids = a
  end

  def selected_ids
    return @selected_ids if @selected_ids
    b = Hash.new
    HASH_KEYS.each do |col|
      b = b.merge(col => Array.new)
    end
    conditions = (@taxonomy.ignore_types.empty? || @taxonomy.ignore_types.first.blank?)  ? "1=1" : "taxable_taxonomies.taxable_type NOT IN ('#{@taxonomy.ignore_types.join("', '")}')"
    selected_groups = @taxonomy.taxable_taxonomies.where(conditions).group_by{|d| d[:taxable_type]}
    selected_groups.each do |k,v|
      b[(k.tableize.singularize+"_ids").to_sym] = v.map{|i| i[:taxable_id]}
    end
    if @taxonomy.is_a?(Location)
      b[:organization_ids] = @taxonomy.organizations.pluck(:id)
    else
      b[:location_ids] = @taxonomy.locations.pluck(:id)
    end
    @selected_ids = b
  end

  def used_and_selected_ids(hosts=nil)
    return @used_and_selected_ids if @used_and_selected_ids
    hosts ||= Host.where(:id => @host.id) if @host
    a = used_ids(hosts)
    b = selected_ids
    c = Hash.new
    HASH_KEYS.each do |col|
      c = c.merge(col => Array.new)
      c[col] = Array(a[col]) & b[col]  # & operator to intersect COMMON elements of arrays
    end
    @used_and_selected_ids = c
  end

  def need_to_be_selected_ids(hosts=nil)
    return @need_to_be_selected_ids if @need_to_be_selected_ids
    hosts ||= Host.where(:id => @host.id) if @host
    a = used_ids(hosts)
    b = selected_ids
    d = Hash.new
    HASH_KEYS.each do |col|
      d = d.merge(col => Array.new)
      d[col] = Array(a[col]) - b[col]  # - operator find NON-common elements of arrays
    end
    #corrections needs
    d[:user_ids] = Array(a[:user_ids]) - b[:user_ids] - User.only_admin.pluck(:id)
    d[:location_ids] = [] if @taxonomy.is_a?(Location)
    d[:organization_ids] = [] if @taxonomy.is_a?(Organization)
    @need_to_be_selected_ids = d
  end

  def missing_ids
    hosts = Host.where(:id => @host.id) if @host
    missing_ids = Array.new
    need_to_be_selected_ids(hosts).each do |key,values|
      taxable_type = hash_key_to_class(key)
      values.each do |v|
        missing_ids << {:taxonomy_id => @taxonomy.id, :taxable_type => taxable_type, :taxable_id => v}
      end
    end
    return missing_ids
  end

  def import_missing_ids
    missing_ids.each do |row|
        # no object for table locations_organizations, so use method *_ids = [array id's]
        if row[:taxable_type] == 'Location'
          org = Organization.find_by_id(row[:taxonomy_id])
          current_location_ids = org.locations.pluck(:id)
          org.location_ids = current_location_ids + row[:taxable_id].to_a
        elsif row[:taxable_type] == 'Organization'
          loc = Location.find_by_id(row[:taxonomy_id])
          current_org_ids = loc.organizations.pluck(:id)
          loc.organization_ids = current_org_ids + row[:taxable_id].to_a
        else
          TaxableTaxonomy.create(:taxonomy_id => row[:taxonomy_id],
                                :taxable_id => row[:taxable_id],
                                :taxable_type => row[:taxable_type])
        end
    end
  end

  def mismatches
    hosts = Host.where(:id => @host.id) if @host
    mismatches = Array.new
    need_to_be_selected_ids(hosts).each do |key,values|
      taxable_type = hash_key_to_class(key)
      values.each do |v|
          taxable_record = taxable_type.constantize.find_by_id(v)
          mismatches << {:taxonomy_id => @taxonomy.id,
                              :taxonomy_name => @taxonomy.name,
                              :taxonomy_type => @taxonomy.class.to_s,
                              :taxable_value => taxable_record.name,
                              :taxable_type => taxable_type
                             }
      end

    end
    @mismatches = mismatches
  end

  # individual methods

  def hash_key_to_class(key)
    key.to_s[0..-5].classify
  end

  #8 regular fk
  def domain_ids(hosts=nil)
    return @host.domain_id if @host
    return [] if @taxonomy.ignore?("Domain")
    if hosts
      hosts.map(&:domain_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:domain_id).uniq.compact
    end
  end
  def subnet_ids(hosts=nil)
    return @host.subnet_id if @host
    return [] if @taxonomy.ignore?("Subnet")
    if hosts
      hosts.map(&:subnet_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:subnet_id).uniq.compact
    end
  end
  def medium_ids(hosts=nil)
    return @host.medium_id if @host
    return [] if @taxonomy.ignore?("Medium")
    if hosts
      hosts.map(&:medium_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:medium_id).uniq.compact
    end
  end
  def environment_ids(hosts=nil)
    return @host.environment_id if @host
    return [] if @taxonomy.ignore?("Environment")
    if hosts
      hosts.map(&:environment_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:environment_id).uniq.compact
    end
  end
  def hostgroup_ids(hosts=nil)
    return @host.hostgroup_id if @host
    return [] if @taxonomy.ignore?("Hostgroup")
    if hosts
      hosts.map(&:hostgroup_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:hostgroup_id).uniq.compact
    end
  end
  def compute_resource_ids(hosts=nil)
    return @host.compute_resource_id if @host
    return [] if @taxonomy.ignore?("ComputeResource")
    if hosts
      hosts.map(&:compute_resource_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:compute_resource_id).uniq.compact
    end
  end
  #orgs and locs can't be ignored
  def location_ids(hosts=nil)
    return @host.location_id if @host
    if hosts
      hosts.map(&:location_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:location_id).uniq.compact
    end
  end
  def organization_ids(hosts=nil)
    return @host.organization_id if @host
    if hosts
      hosts.map(&:organization_id).uniq.compact
    else
      @taxonomy.hosts.pluck(:organization_id).uniq.compact
    end
  end
  # populate used_ids for 3 non-standard_id's
  def user_ids(hosts=nil)
    return @host.owner_id if @host && @host.owner_type == "User"
    return [] if @taxonomy.ignore?("User")
    if hosts
      hosts.where(:owner_type => 'User').map(&:owner_id).uniq.compact
    else
      @taxonomyhosts.where(:owner_type => 'User').map(&:owner_id).uniq.compact
    end
  end
  def config_template_ids(hosts=nil)
    if @host
      return @host.configTemplate.try(:id) if @host.operatingsystem
    end
    return [] if @taxonomy.ignore?("ConfigTemplate")
    hosts ||= @taxonomy.hosts
    ConfigTemplate.template_ids_for(hosts)
  end
  def smart_proxy_ids(hosts=nil)
    return @host.smart_proxy_ids if @host
    return [] if @taxonomy.ignore?("SmartProxy")
    hosts ||= @taxonomy.hosts
    SmartProxy.smart_proxy_ids_for(hosts)
  end
    # retrieve hosts that belong to taxonomy
    #hosts_array = hosts.all
    # 8 _id's have regular foreign _id keys
    #columns = [:location_id, :organization_id, :hostgroup_id, :environment_id, :domain_id, :medium_id,
    #           :subnet_id, :compute_resource_id].sort
    #select_columns = columns.map {|i| "hosts.#{i}"}
    # 3 _id's that are NOT regular foreign keys - [:smart_proxy_ids, :user_ids, :config_template_ids]
    #todo - test fails if I add .select(select_columns+['hosts.id, hosts.operatingsystem_id', 'hosts.owner_id'])

end
