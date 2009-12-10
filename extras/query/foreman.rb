require 'yaml'
require 'net/http'

# returns an array of hosts
# expects a hash with facts and classes - e.g.:
#{"fact"=>{"domain"=>"domain", "puppetversion"=>"0.24.4"}, "class" => ["common","my_special_class"]}
def gethosts(query = {})
  url="http://foreman:3000"
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
    self.each do |type,name|
      case type.to_s
      when "fact"
        name.each { |k,v| fact << "fact[]=#{k}-#{v}" }
      when "class"
        name.each { |c| klass << "class[]=#{c}" }
      else
        raise "unknown query type #{type}"
      end
    end
    return (fact + klass).join("&")
  end
end

