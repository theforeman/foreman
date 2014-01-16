object @console

attributes :name => :host
attributes :type

node do |r|
  partial("api/v2/compute_resources/#{r.type.downcase}.json", :object => r)
end
