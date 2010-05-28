require 'yaml'
require 'net/http'

# returns an array of hosts
# expects a hash with facts and classes - e.g.:
#{"fact"=>{"domain"=>"domain", "puppetversion"=>"0.24.4"}, "class" => ["common","my_special_class"], "state" => "all", "hostgroup" => "common"}
def gethosts(query = {})
  url="http://localhost:3000"
  begin
    result = YAML::load(Net::HTTP.get(URI.parse("#{url}/hosts/query?#{query.to_url}&format=yml")))
    result == "404 Not Found" ? nil : result
  rescue Exception => e
    raise e
  end
end

# converts an hash to a valid URL
class Hash
  def to_url
    fact=[]
    klass=[]
    group=[]
    state = ""
    verbose = ""
    self.each do |type,name|
      case type.to_s
      when "fact"
        name.each { |k,v| fact << "fact[]=#{k}-seperator-#{URI.escape(v)}" }
      when "class"
        name.each { |c| klass << "class[]=#{c}" }
      when "hostgroup"
        name.each { |c| group << "hostgroup[]=#{c}" }
      when "state"
        state = "state=#{name}"
      when "verbose"
        verbose = "verbose=#{name}"
      else
        raise "unknown query type #{type}"
      end
    end
    return (fact + klass + group).join("&")+"&#{state}&#{verbose}"
  end
end

