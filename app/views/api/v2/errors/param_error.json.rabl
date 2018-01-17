exception = locals[:exception]

object exception => :error

node :message do
  locals[:message] || exception.message
end
node(:class) { exception.class.to_s }
node(:parameter_name) { exception.param } if exception.respond_to? :param
node(:parameter_names) { exception.params } if exception.respond_to? :params
