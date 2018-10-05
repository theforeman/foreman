module HostStatus
  class Global
    OK = 0
    WARN = 1
    ERROR = 2

    attr_accessor :status

    def self.build(statuses, options = {})
      relevant_statuses = statuses.select do |s|
        s.relevant?(options) && !s.substatus?
      end

      max_status = relevant_statuses.map { |s| s.to_global(options) }.max

      new(max_status || OK)
    end

    def self.status_name
      N_('Global')
    end

    def name
      self.class.status_name
    end

    def initialize(status)
      self.status = status
    end

    def to_label
      case status
        when OK
          N_('OK')
        when WARN
          N_('Warning')
        when ERROR
          N_('Error')
        else
          raise 'Unknown global status'
      end
    end
  end
end
