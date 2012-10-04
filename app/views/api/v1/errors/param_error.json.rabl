exception = locals[:exception]

object exception => :error

attributes :message
node(:class) { exception.class.to_s }
node(:parameter_name) { exception.param } if exception.respond_to? :param
