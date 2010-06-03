require 'puppet'
require 'gchart'

# import settings file
SETTINGS= YAML.load_file("#{RAILS_ROOT}/config/settings.yaml")
# fallback to a 30 minutes run interval if its not defined
SETTINGS[:puppet_interval] ||= 30
SETTINGS[:run_interval] = SETTINGS[:puppet_interval].minutes

Puppet[:config] = SETTINGS[:puppetconfdir] || "/etc/puppet/puppet.conf"
Puppet.parse_config
$puppet = Puppet.settings.instance_variable_get(:@values) if Rails.env == "test"

# Add an empty method to nil. Now no need for if x and x.empty?. Just x.empty?
class NilClass
  def empty?
    true
  end
end

class ActiveRecord::Base

  def update_single_attribute(attribute, value)
    connection.update(
      "UPDATE #{self.class.table_name} " +
      "SET #{attribute.to_s} = #{value} " +
      "WHERE #{self.class.primary_key} = #{id}",
      "#{self.class.name} Attribute Update"
    )
  end
  class Ensure_not_used_by
    def initialize(*attribute)
      @klasses = attribute
      @logger  = RAILS_DEFAULT_LOGGER
    end

    def before_destroy(record)
      for klass in @klasses
        for what in eval "record.#{klass.to_s}"
          record.errors.add_to_base(record.to_label + " is used by " + what.to_s)
        end
      end
      unless record.errors.empty?
        @logger.error "You may not destroy #{record.to_label} as it is in use!"
        false
      else
        true
      end
    end
  end

  def id_and_type
    "#{id}-#{self.class.table_name.humanize}"
  end
  alias_attribute :to_label, :name
  alias_attribute :to_s, :to_label

  def self.per_page
    20
  end

  def self.unconfigured?
    count == 0
  end

end

module ExemptedFromLogging
  def process(request, *args)
    logger.silence { super }
  end
end

class String
  def to_gb
    begin
      value,unit=self.match(/(\d+|.+) ([KMG]B)$/i)[1..2]
      case unit.to_sym
      when nil, :B, :byte          then (value.to_f / 1000_000_000)
      when :GB, :G, :gigabyte      then value.to_f
      when :MB, :M, :megabyte      then (value.to_f / 1000)
      when :KB, :K, :kilobyte, :kB then (value.to_f / 1000_000)
      else raise "Unknown unit: #{unit.inspect}!"
      end
    rescue
      raise "Unknown string"
    end
  end
end
module ActionView::Helpers::ActiveRecordHelper
  def error_messages_for_with_customisation(*params)
    if flash[:error_customisation]
      if params[-1].is_a? Hash
        params[-1].update flash[:error_customisation]
      else
        params << flash[:error_customisation]
      end
    end
    error_messages_for_without_customisation(*params)
  end
  alias_method_chain :error_messages_for, :customisation
end
