module Foreman

  # Simple struct for manipulation and comparing versions
  class Version
    attr_reader :version, :major, :minor, :build, :tag, :short, :notag, :prerelease
    alias :full :version

    def initialize givenversion=nil
      if givenversion
        @version = givenversion
      else
        root = File.expand_path(File.dirname(__FILE__) + "/../../..")
        @version = File.read(root + "/VERSION").chomp # or fail if not found
      end
      @major, @minor, @build = @version.scan(/\d+/)
      @short = "#{@major}.#{@minor}"
      @prerelease = @version.split('-')[1]

      if @version =~ /\A(.*)-([^-]+)\z/
        @notag = $1
        @tag = $2
      else
        @notag = @version
        @tag = ""
      end
    end

    def to_s
      @version
    end

    def short_latest_stable
      @prerelease && @minor.to_i > 0 ? (@short.to_f - 0.1).to_s : @short
    end

  end

end
