class Puppetclass < ActiveRecord::Base
  include Authorizable
  before_destroy EnsureNotUsedBy.new(:hosts, :hostgroups)
  has_many :environment_classes, :dependent => :destroy
  has_many :environments, :through => :environment_classes, :uniq => true
  has_and_belongs_to_many :operatingsystems
  has_many :hostgroup_classes, :dependent => :destroy
  has_many :hostgroups, :through => :hostgroup_classes
  has_many :host_classes, :dependent => :destroy
  has_many_hosts :through => :host_classes

  has_many :lookup_keys, :inverse_of => :puppetclass, :dependent => :destroy
  accepts_nested_attributes_for :lookup_keys, :reject_if => lambda { |a| a[:key].blank? }, :allow_destroy => true
  # param classes
  has_many :class_params, :through => :environment_classes, :uniq => true,
    :source => :lookup_key, :conditions => 'environment_classes.lookup_key_id is NOT NULL'
  accepts_nested_attributes_for :class_params, :reject_if => lambda { |a| a[:key].blank? }, :allow_destroy => true
  validates :name, :uniqueness => true, :presence => true, :format => {:with => /\A(\S+\s?)+\Z/, :message => N_("can't be blank or contain white spaces.") }
  audited :allow_mass_assignment => true

  alias_attribute :smart_variables, :lookup_keys
  alias_attribute :smart_variable_ids, :lookup_key_ids
  alias_attribute :smart_class_parameters, :class_params
  alias_attribute :smart_class_parameter_ids, :class_param_ids

  default_scope lambda { order('puppetclasses.name') }

  scoped_search :on => :name, :complete_value => :true
  scoped_search :in => :environments, :on => :name, :complete_value => :true, :rename => "environment"
  scoped_search :in => :hostgroups,   :on => :name, :complete_value => :true, :rename => "hostgroup"
  scoped_search :in => :hosts, :on => :name, :complete_value => :true, :rename => "host", :ext_method => :search_by_host, :only_explicit => true
  scoped_search :in => :class_params, :on => :key, :complete_value => :true

  scope :not_in_any_environment, includes(:environment_classes).where(:environment_classes => {:environment_id => nil})

  def to_param
    name
  end

  # returns a hash containing modules and associated classes
  def self.classes2hash classes
    hash = {}
    for klass in classes
      if (mod = klass.module_name)
        hash[mod] ||= []
        hash[mod] << klass
      else
        next
      end
    end
    return hash
  end

  # For API v2 - eliminate node :puppetclass for each object. returns a hash containing modules and associated classes
  def self.classes2hash_v2 classes
    hash = {}
    classes.each do |klass|
      if (mod = klass.module_name)
        hash[mod] ||= []
        hash[mod] << {:id => klass.id, :name => klass.name, :created_at => klass.created_at, :updated_at => klass.updated_at}
      end
    end
    return hash
  end

  # returns module name (excluding of the class name)
  # if class separator does not exists (the "::" chars), then returns the whole class name
  def module_name
    (i = name.index("::")) ? name[0..i-1] : name
  end

  # returns class name (excluding of the module name)
  def klass
    name.gsub(module_name+"::","")
  end

  # Populates the rdoc tree with information about all the classes in your modules.
  #   Firstly, we prepare the modules tree
  #   Secondly we run puppetdoc over the modulespath and manifestdir for all environments
  # The results are written into document_root/puppet/rdoc/<env>/<class>"
  def self.rdoc root
    debug, verbose = false, false
    relocated      = root != "/"             # This is true if the prepare phase copied the modules tree

    # Retrieve an optional http server's DocumentRoot from the settings.yaml file, and prepare it for writing
    doc_root = Pathname.new(Setting[:document_root])
    doc_root.mkpath
    unless doc_root.directory? and doc_root.writable?
      puts "Unable to write html to #{doc_root}"
      return false
    end
    validator = '<div id="validator-badges">'
    # For each environment we write a puppetdoc tree
    for env, path in Environment.puppetEnvs
      # We may need to rewrite the modulepaths because they have been changed by the prepare step
      modulepaths = relocated ? path.split(":").map{|p| root + p}.join(":") : path

      # Identify and prepare the output directory
      out = doc_root + env
      out.rmtree if out.directory?

      replacement = "<div id=\\\"validator-badges\\\"><small><a href=\\\"/puppet/rdoc/#{env}/\\\">[Browser]</a></small>"

      # Create the documentation

      puts "*********Proccessing environment #{env} *************"
      cmd = "puppetdoc --output #{out} --modulepath #{modulepaths} -m rdoc"
      puts cmd if defined?(Rake)
      sh cmd do |ok, res|
        if ok
          # Add a link to the class browser
          files =  %x{find #{out} -exec grep -l 'validator-badges' {} \\; 2>/dev/null}.gsub(/\n/, " ")
          if files.empty?
            warn "No files to update with the browser link in #{out}. This is probably due to a previous error."
          else
            cmd = "ruby -p -i -e '$_.gsub!(/#{validator}/,\"#{replacement}\")' #{files}"
            puts cmd if debug
           sh cmd
          end
          # Relocate the paths for files and references if the manifests were relocated and sanitized
          if relocated and (files = %x{find #{out} -exec grep -l '#{root}' {} \\;}.gsub(/\n/, " ")) != ""
            puts "Rewriting..." if verbose
            cmd = "ruby -p -i -e 'rex=%r{#{root}};$_.gsub!(rex,\"\")' #{files}"
            puts cmd if debug
            sh cmd
            # Now relocate the files/* files to match the rewritten url
            mv Dir.glob("#{out}/files/#{root}/*"), "#{out}/files", :verbose => verbose
          end
        else
          logger.warn "Failed to process puppetdocs for #{out} while executing #{cmd}"
          puts "Failed to process puppetdocs for #{out} while executing #{cmd}"
        end
      end
      puts
    end
  end

  # Optionally creates a copy of the current puppet modules and sanitizes it.
  # If your 'live' manifests and modules can be parsed by puppetdoc
  # then you do not need to do this step. (Unfortunately some sites have circular
  # symlinks which have to be removed.)
  # If the executable Rails,root/script/rdoc_prepare_script exists then it is run
  # and passed a list of all directory paths in all environments.
  # It should return the directory into which it has copied the cleaned modules"
  def self.prepare_rdoc root
    debug, verbose = false, false

    prepare_script = Pathname.new(Rails.root) + "script/rdoc_prepare_script.rb"
    if prepare_script.executable?
      dirs = Environment.puppetEnvs.values.join(":").split(":").uniq.sort.join(" ")
      puts "Running #{prepare_script} #{dirs}" if debug
      location = %x{#{prepare_script} #{dirs}}
      if $? == 0
        root = location.chomp
        puts "Relocated modules to #{root}" if verbose
      end
    else
      puts "No executable #{prepare_script} found so using the uncopied module sources" if verbose
    end
    root
  end

  def self.search_by_host(key, operator, value)
    conditions = sanitize_sql_for_conditions(["hosts.name #{operator} ?", value_to_sql(operator, value)])
    direct     = Puppetclass.joins(:hosts).where(conditions).select('puppetclasses.id').map(&:id).uniq
    hostgroup  = Hostgroup.joins(:hosts).where(conditions).first
    indirect   = hostgroup.blank? ? [] : HostgroupClass.where(:hostgroup_id => hostgroup.path_ids).pluck('DISTINCT puppetclass_id')
    return { :conditions => "1=0" } if direct.blank? && indirect.blank?

    puppet_classes = (direct + indirect).uniq
    { :conditions => "puppetclasses.id IN(#{puppet_classes.join(',')})" }
  end


  def self.value_to_sql(operator, value)
    return value                 if operator !~ /LIKE/i
    return value.tr_s('%*', '%') if (value ~ /%|\*/)

    return "%#{value}%"
  end

end
