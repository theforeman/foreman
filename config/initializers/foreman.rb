require 'puppet'
require 'gchart'

# import settings file
SETTINGS= YAML.load_file("#{RAILS_ROOT}/config/settings.yaml")
# fallback to a 30 minutes run interval if its not defined
SETTINGS[:puppet_interval] = 30 if SETTINGS[:puppet_interval].nil?
SETTINGS[:run_interval] = SETTINGS[:puppet_interval].minutes

Puppet[:config] = SETTINGS[:puppetconfdir] || "/etc/puppet/puppet.conf"
Puppet.parse_config

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
  private
  def ensure_not_used
    self.hosts.each do |host|
      errors.add_to_base to_label + " is used by " + host.to_label
    end
    raise ApplicationController::InvalidDeleteError.new, errors.full_messages.join("<br>") unless errors.empty?
    true
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
