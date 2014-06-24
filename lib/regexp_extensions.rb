# From ruby_parser 3.x to fix warnings under ruby_parser 2.x
#
# ruby2ruby sets some constants, but not ONCE.  ruby_parser 2.x checks for
# ONCE and then causes duplicate definitions of ENC_*.
class Regexp
  ONCE = 0 unless defined? ONCE # FIX: remove this - it makes no sense

  unless defined? ENC_NONE then
    ENC_NONE = /x/n.options
    ENC_EUC  = /x/e.options
    ENC_SJIS = /x/s.options
    ENC_UTF8 = /x/u.options
  end
end
