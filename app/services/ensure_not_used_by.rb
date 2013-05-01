  # ActiveRecord Callback class
  class EnsureNotUsedBy
    attr_reader :klasses, :logger
    def initialize *attribute
      @klasses = attribute
      @logger  = Rails.logger
    end

    def before_destroy(record)
      klasses.each do |klass|
        record.send(klass.to_sym).each do |what|
          record.errors.add :base, "#{record} is used by #{what}"
        end
      end
      if record.errors.empty?
        true
      else
        logger.error "You may not destroy #{record.to_label} as it is in use!"
        false
      end
    end
  end
