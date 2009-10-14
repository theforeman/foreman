require 'net/http'

# Query Foreman
module Puppet::Parser::Functions
 newfunction(:foreman, :type => :rvalue) do |args|
	#URL to query
	host = "foreman"
  url = "/query?"
  query = []
  args.each do |arg|
    name, value = arg.split("=")
    case name
    when "fact", "class"
      query << "#{name}=#{value}"
    when "verbose"
      query << "verbose=yes" if value == "yes"
    else
      raise Puppet::ParseError, "Foreman: Invalid parameter #{name}"
    end
  end

  begin
    response = Net::HTTP.get host,url+query.join("&")
  rescue Exception => e
    raise Puppet::ParseError, "Failed to contact Foreman #{e}"
  end

  begin
    hostlist = YAML::Load response
  rescue Exception => e
    raise Puppet::ParseError, "Failed to parse response from Foreman #{e}"
  end
	return response
 end
end
