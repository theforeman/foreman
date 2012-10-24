exception = locals[:exception]

object exception => :error

attributes :message
attributes :backtrace if Rails.env.development?
node(:class) { exception.class.to_s }
