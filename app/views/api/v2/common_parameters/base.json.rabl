object @common_parameter

attributes :id, :name, :parameter_type

node do
  partial("api/v2/common/show_hidden", :locals => { :value => :value }, :object => @object)
end
