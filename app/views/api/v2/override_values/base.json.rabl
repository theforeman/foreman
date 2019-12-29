object @override_value

attributes :id, :match, :value, :omit

node do
  partial("api/v2/common/show_hidden", :locals => { :value => :value }, :object => @object)
end
