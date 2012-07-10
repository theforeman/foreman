error = locals[:error]

object error => :error

attributes :message, :backtrace
node(:class) { error.class.to_s }