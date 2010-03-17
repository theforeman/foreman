class Puppetclass < ActiveRecord::Base
  has_and_belongs_to_many :environments
  has_and_belongs_to_many :operatingsystems
  has_and_belongs_to_many :hosts
  has_and_belongs_to_many :hostgroups

  validates_uniqueness_of :name
  validates_presence_of :name
  validates_associated :environments
  validates_format_of :name, :with => /\A(\S+\s?)+\Z/, :message => "can't be blank or contain white spaces."
  acts_as_audited
  default_scope :order => "name"

  before_destroy Ensure_not_used_by.new(:hosts)
  before_destroy Ensure_not_used_by.new(:hostgroups)

  # scans for puppet classes
  # parameter is the module path
  # returns an array of puppetclasses objects
  def self.scanForClasses(path)
    klasses=Array.new
    Dir.glob("#{path}/*/manifests/**/*.pp").each do |manifest|
      File.read(manifest).each_line do |line|
        klass=line.match(/^class (\S+).*\{/)
        klasses << Puppetclass.find_or_create_by_name(klass[1]) if klass
      end
    end
    return klasses
  end

  def to_s
    name
  end

  # returns a hash containing modules and associated classes
  def self.classes2hash classes
    hash = {}
    for klass in classes
      if mod = klass.module_name
        hash[mod] ||= []
        hash[mod] << klass
      else
        next
      end
    end
    return hash
  end

  # returns module name (excluding of the class name)
  # if class seperator does not exists (the "::" chars), then returns the whole class name
  def module_name
    return (i = name.index("::")) ? name[0..i-1] : name
  end

  # returns class name (excluding of the module name)
  def klass
    return name.gsub(module_name+"::","")
  end

  # add sort by class name
  def <=>(other)
    klass <=> other.klass
  end

  def self.per_page
    20
  end

  # Retrieve the manifestdir from the puppet configuration
  # Returns: String
  def self.manifestdir
    ps =  Puppet.settings.instance_variable_get(:@values)
    ps[:main][:manifestdir] || ps[:puppetmasterd][:manifestdir] || ps[:puppetd][:manifestdir] || Puppet.settings[:manifestdir] || "/etc/puppet/manifests"
  end

  # Populates the rdoc tree with information about all the classes in your modules.
  #   Firstly, we prepare the modules tree
  #   Secondly we run puppetdoc over the modulespath and manifestdir for all environments
  # The results are written into document_root/puppet/rdoc/<env>/<class>"
  def self.rdoc root
    debug, verbose = false, false
    relocated      = root != "/"             # This is true if the prepare phase copied the modules tree

    # Retrieve an optional http server's DocumentRoot from the settings.yaml file, and prepare it for writing
    doc_root = Pathname.new(SETTINGS[:document_root] || RAILS_ROOT + "/public") + "puppet/rdoc"
    doc_root.mkpath
    unless doc_root.directory? and doc_root.writable?
      puts "Unable to write html to #{doc_root}"
      return false
    end
    # For each environment we write a puppetdoc tree
    for env, path in Environment.puppetEnvs
      # We may need to rewrite the modulepaths because they have been changed by the prepare step
      modulepaths = relocated ? path.split(":").map{|p| root + p}.join(":") : path

      # Identify and prepare the output directory
      out = doc_root + env.id2name
      out.rmtree if out.directory?

      # Create the documentation
      cmd = "puppetdoc -o #{out} --modulepath #{modulepaths} --manifestdir #{manifestdir} -m rdoc"
      sh %{#{cmd} #{verbose ? "" : "2>/dev/null"}} do |ok, res|
        if ok
          if relocated and (files = %x{find #{out} -exec grep -l '#{root}' {} \\;}.gsub(/\n/, " ")) != ""
            puts "Rewriting..." if verbose
            cmd = "ruby -p -i -e 'rex=%r{#{root}};$_.gsub!(rex,\"\")' #{files}"
            puts cmd if debug
            %x{#{cmd}}
            # Now relocate the files/* files to match the rewritten url
            mv Dir.glob("#{out}/files/#{root}/*"), "#{out}/files", :verbose => verbose
          end
        else
          puts "Failed to process puppetdocs for #{out}"
        end
      end
    end
  end

  # Optionally creates a copy of the current puppet modules and sanitizes it.
  # If your 'live' manifests and modules can be parsed by puppetdoc
  # then you do not neeed to do this step. (Unfortunately some sites have circular
  # symlinks which have to be removed.)
  # If the executable RAILS_ROOT/script/rdoc_prepare_script exists then it is run
  # and passed a list of all directory paths in all environments.
  # It should return the directory into which it has copied the cleaned modules"
  def self.prepare_rdoc root
    debug, verbose = false, false

    prepare_script = Pathname.new(RAILS_ROOT) + "script/rdoc_prepare_script.rb"
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
end
