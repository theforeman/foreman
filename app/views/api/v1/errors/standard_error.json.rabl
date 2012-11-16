exception = locals[:exception]

object exception => :error

attributes :message, :backtrace
node(:class) { exception.class.to_s }
