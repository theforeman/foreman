module Foreman
  # Simple struct for manipulation and comparing versions
  class Version
    attr_reader :version, :major, :minor, :build, :tag, :short, :notag
    alias_method :full, :version

    def initialize(givenversion = nil)
      if givenversion
        @version = givenversion
      else
        root = File.expand_path(File.dirname(__FILE__) + "/../../..")
        @version = File.read(root + "/VERSION").chomp # or fail if not found
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
  end
end
