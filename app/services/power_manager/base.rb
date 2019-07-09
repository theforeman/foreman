module PowerManager
  class Base
    def initialize(opts = {})
      @host = opts[:host]
    end

    def self.method_missing(method, *args)
      super
    rescue NoMethodError
      logger.warn "invalid power state request #{action} for host: #{host}"
      raise ::Foreman::Exception.new(N_("Invalid power state request: %{action}, supported actions are %{supported}"), { :action => action, :supported => SUPPORTED_ACTIONS })
    end

    def self.respond_to_missing?(method_name, include_private = false)
      super
    end

    SUPPORTED_ACTIONS.each do |method|
      define_method method do # def start
        action_entry = find_action_entry(method)
        method_to_call = action_entry[:action]
        if method_to_call
          result = send(method_to_call)
        else
          result = default_action(method.to_sym)
        end
        result = send(action_entry[:output], result) if action_entry[:output]
        result
      end
    end

    def logger
      Rails.logger
    end

    protected

    def default_action(action)
      raise NotImplementedError.new
    end

    def action_map
      {
        :status => { :output => :translate_status },
      }
    end

    def translate_status(result)
      result = result.to_s
      return N_("Unknown") if result.empty?
      return 'on' if result =~ /on/i
      return 'off' if result =~ /off/i
      result
    end

    private

    attr_reader :host

    def find_action_entry(method)
      action_entry = action_map[method.to_sym] || {} # create a valid entry
      # if action_map is in simple format (:key => 'method'), transform it to entry
      action_entry = {:action => action_entry.to_sym} unless action_entry.is_a?(Hash)
      action_entry
    end
  end
end
