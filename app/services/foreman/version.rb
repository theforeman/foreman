module Foreman
  # Simple struct for manipulation and comparing versions
  class Version
    attr_reader :version, :major, :minor, :build, :tag, :short, :notag
    alias_method :full, :version

    def initialize(givenversion = nil)
      if givenversion
        @version = givenversion
      elsif File.exist?(File.join(root, '.git'))
        command = ['git', '--git-dir', File.join(root, '.git'), 'describe']
        @version = IO.popen(command) { |f| f.readline }.chomp
      else
        @version = File.read(File.join(root, "VERSION")).chomp # or fail if not found
      end
      @major, @minor, @build = @version.scan(/\d+/)
      @short = "#{@major}.#{@minor}"

      if @version =~ /\A(.*)-([^-]+)\z/
        @notag = Regexp.last_match(1)
        @tag = Regexp.last_match(2)
      else
        @notag = @version
        @tag = ""
      end
    end

    def to_s
      @version
    end

    private

    # Find the rails root. This is undefined in very early init
    def root
      Rails.root || File.join(__dir__, '..', '..', '..')
    end
  end
end
