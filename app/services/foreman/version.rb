module Foreman

  # Simple struct for manipulation and comparing versions
  class Version
    attr_reader :version, :major, :minor, :build, :tag, :short
    alias :full :version

    def initialize givenversion=nil
      if givenversion
        @version = givenversion
      else
        root = File.expand_path(File.dirname(__FILE__) + "/../../..")
        @version = File.read(root + "/VERSION").chomp # or fail if not found
      end
      @major, @minor, @build = @version.scan(/\d+/)
      @tag = @version.include?('-') ? @version.split('-').last : "" rescue ""
      @short = "#{@major}.#{@minor}"
    end

    def to_s
      @version
    end
  end

end
