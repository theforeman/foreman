object @parameter

attributes :id, :name, :parameter_type, :associated_type, :hidden_value?

node do
  partial("api/v2/common/show_hidden", :locals => { :value => :value }, :object => @object)
end
