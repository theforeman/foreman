class Os < ActiveRecord::Base
    has_many :hosts
    belongs_to :architecture
    has_one :media
    validates_presence_of :major, :message => "Operating System version is required"
    validates_presence_of :name
    validates_uniqueness_of :name 
    validates_associated :media, :architecture

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

end
