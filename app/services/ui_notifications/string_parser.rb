module UINotifications
  # class to convert blueprint and url title templates into strings
  class StringParser
    def initialize(template, options = {})
      @template = template
      @options = options
    end

    def to_s
      template % options
    end

    private

    attr_reader :template, :options
  end
end
