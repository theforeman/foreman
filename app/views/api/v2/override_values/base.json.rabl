object @override_value

attributes :id, :match, :value, :omit
# compatibility
attribute :omit => :use_puppet_default

node do
  partial("api/v2/common/show_hidden", :locals => { :value => :value }, :object => @object)
end
