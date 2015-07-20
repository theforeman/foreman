require 'securerandom'

#Common methods between host and hostgroup
# mostly for template rendering consistency
module HostCommon
  extend ActiveSupport::Concern

  included do
    include CounterCacheFix

    counter_cache = "#{model_name.split(":").first.pluralize.downcase}_count".to_sym  # e.g. :hosts_count

    belongs_to :architecture,    :counter_cache => counter_cache
    belongs_to :environment,     :counter_cache => counter_cache
    belongs_to :operatingsystem, :counter_cache => counter_cache
    belongs_to :medium
    belongs_to :ptable
    belongs_to :realm,           :counter_cache => counter_cache
    belongs_to :compute_profile

    before_save :crypt_root_pass

    has_many :host_config_groups, :as => :host
    has_many :config_groups, :through => :host_config_groups, :after_add => :update_config_group_counters,
                                                              :after_remove => :update_config_group_counters
    has_many :config_group_classes, :through => :config_groups

    has_many :lookup_values, :finder_sql => Proc.new { LookupValue.where('lookup_values.match' => lookup_value_match).to_sql }, :dependent => :destroy, :validate => false
    # See "def lookup_values_attributes=" under, for the implementation of accepts_nested_attributes_for :lookup_values
    accepts_nested_attributes_for :lookup_values
    # Replacement of accepts_nested_attributes_for :lookup_values,
    # to work around the lack of `host_id` column in lookup_values.
    def lookup_values_attributes=(lookup_values_attributes)
      lookup_values_attributes.each_value do |attribute|
        attr = attribute.dup
        if attr.has_key? :id
          lookup_value = lookup_values.find attr.delete(:id)
          if lookup_value
            mark_for_destruction = ActiveRecord::ConnectionAdapters::Column.value_to_boolean attr.delete(:_destroy)
            lookup_value.attributes = attr
            mark_for_destruction ? lookup_values.delete(lookup_value) : lookup_value.save!
          end
        elsif !ActiveRecord::ConnectionAdapters::Column.value_to_boolean attr.delete(:_destroy)
          LookupValue.create(attr.merge(:match => lookup_value_match, :host_or_hostgroup => self))
        end
      end
    end
  end

  # Returns a url pointing to boot file
  def url_for_boot(file)
    "#{os.medium_uri(self)}/#{os.url_for_boot(file)}"
  end

  def puppetca?
    raise "Old design"
  end

  # no need to store anything in the db if the entry is plain "puppet"
  # If the system is using smart proxies and the user has run the smartproxy:migrate task
  # then the puppetmaster functions handle smart proxy objects
  def puppetmaster
    raise "Old design"
  end

  def puppet_ca_server
    raise "Old design"
  end

  # If the host/hostgroup has a medium then use the path from there
  # Else if the host/hostgroup's operatingsystem has only one media then use the image_path from that as this is automatically displayed when there is only one item
  # Else we cannot provide a default and it is cut and paste time
  def default_image_file
    return "" unless operatingsystem and operatingsystem.supports_image
    if medium
      nfs_path = medium.try :image_path
      if operatingsystem.try(:media) and operatingsystem.media.size == 1
        nfs_path ||= operatingsystem.media.first.image_path
      end
      # We encode the hw_model into the image file name as not all Sparc flashes can contain all possible hw_models. The user can always
      # edit it if required or use symlinks if they prefer.
      hw_model = model.try :hardware_model if defined?(model_id)
      operatingsystem.interpolate_medium_vars(nfs_path, architecture.name, operatingsystem) +\
        "#{operatingsystem.file_prefix}.#{architecture}#{hw_model.empty? ? "" : "." + hw_model.downcase}.#{operatingsystem.image_extension}"
    else
      ""
    end
  end

  def image_file=(file)
    # We only save a value into the image_file field if the value is not the default path, (which was placed in the entry when it was displayed,)
    # and it is not a directory, (ends in /)
    value = ( (default_image_file == file) or (file =~ /\/\Z/) or file == "") ? nil : file
    write_attribute :image_file, value
  end

  def image_file
    super || default_image_file
  end

  def crypt_root_pass
    # hosts will always copy and crypt the password from parents when saved, but hostgroups should
    # only crypt if the attribute is stored, else will stay blank and inherit
    unencrypted_pass = if is_a?(Hostgroup)
                         read_attribute(:root_pass)
                       else
                         root_pass
                       end

    if unencrypted_pass.present?
      is_actually_encrypted = if PasswordCrypt.crypt_gnu_compatible?
                                unencrypted_pass.match('^\$\d+\$.+\$.+')
                              else
                                unencrypted_pass.starts_with?("$")
                              end

      if is_actually_encrypted
        self.root_pass =  self.grub_pass = unencrypted_pass
      else
        self.root_pass = operatingsystem.nil? ? PasswordCrypt.passw_crypt(unencrypted_pass) : PasswordCrypt.passw_crypt(unencrypted_pass, operatingsystem.password_hash)
        self.grub_pass = PasswordCrypt.grub2_passw_crypt(unencrypted_pass)
      end
    end
  end

  def param_true?(name)
    params.has_key?(name) && Foreman::Cast.to_bool(value)
  end

  def param_false?(name)
    params.has_key?(name) && Foreman::Cast.to_bool(value) == false
  end

  def cg_class_ids
    cg_ids = if is_a?(Hostgroup)
               path.each.map(&:config_group_ids).flatten.uniq
             else
               config_group_ids + (hostgroup ? hostgroup.path.each.map(&:config_group_ids).flatten.uniq : [] )
             end
    ConfigGroupClass.where(:config_group_id => cg_ids).pluck(:puppetclass_id)
  end

  def hg_class_ids
    hg_ids = if is_a?(Hostgroup)
               path_ids
             elsif hostgroup
               hostgroup.path_ids
             end
    HostgroupClass.where(:hostgroup_id => hg_ids).pluck(:puppetclass_id)
  end

  def host_class_ids
    debugger
    throw 'Old code'
  end

  def all_puppetclass_ids
    debugger
    throw 'Old code'
  end

  def classes(env = environment)
    debugger
    throw 'Old code'
  end

  def puppetclass_ids
    debugger
    throw 'Old code'
  end

  def classes_in_groups
    debugger
    throw 'Old code'
  end

  def individual_puppetclasses
    debugger
    throw 'Old code'
  end

  def available_puppetclasses
    debugger
    throw 'Old code'
  end

  private

  def cnt_hostgroups(config_group)
    Hostgroup.search_for(%{config_group="#{config_group.name}"}).count
  end

  def cnt_hosts(config_group)
    Host::Managed.search_for(%{config_group="#{config_group.name}"}).count
  end

  def update_config_group_counters(record)
    record.update_attribute(:hostgroups_count, cnt_hostgroups(record))
    record.update_attribute(:hosts_count, cnt_hosts(record))

    record.update_puppetclasses_total_hosts
  end
end
