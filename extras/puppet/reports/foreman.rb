# copy this file to your report dir - e.g. /usr/lib/ruby/1.8/puppet/reports/
# add this report in your puppetmaster reports - e.g, in your puppet.conf add:
# reports=log, foreman # (or any other reports you want)
# Dont forget to update the URL of your Foreman installation

require 'puppet'
require 'net/http'
require 'uri'

Puppet::Reports.register_report(:foreman) do
    Puppet.settings.use(:reporting)
    desc "Sends reports directly to Foreman"

    def process
      begin
        Net::HTTP.post_form(URI.parse('http://foreman:3000/reports/create?format=yml'), {'report'=> to_yaml})
      rescue Exception => e
        raise Puppet::Error, "Could not send report to Foreman: #{e}"
      end
    end
end
