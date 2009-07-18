class Os < ActiveRecord::Base
    has_many :hosts
    belongs_to :architecture
    has_one :media
    validates_presence_of :major, :message => "Operating System version is required"
    validates_presence_of :name, :architecture_id, :media_id
    validates_uniqueness_of :name 

    before_destroy :ensure_not_used

    # shortcut for just typing arch
    alias_attribute :arch, :architecture

    # The OS is usually represented as the catenation of the OS and the revision. E.G. "Solaris 10"
    def to_label
      "#{name} #{major}#{('.' + minor) unless minor.empty?}"
    end

    def to_s
      to_label
    end

    private
    # This is a before_destroy callback that ensures that the operatingsystem is
    # not removed if any host is currently using it.
    # It will populate self.errors with a list of hosts using this operatingsystem
    # Returns: True if no host uses this goldimage
    def ensure_not_used
      self.hosts.each do |host|
        errors.add_to_base number + " is used by " + host.name
      end
      raise ApplicationController::InvalidDeleteError.new, errors.full_messages.join("<br>") unless errors.empty?
      true
    end
end
