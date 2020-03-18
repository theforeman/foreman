require 'uri'

class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default :delivery_method => proc { Setting[:delivery_method] },
          :from => proc { Setting[:email_reply_address] || "noreply@foreman.example.org" }
  after_action :set_delivery_options

  def mail(headers = {}, &block)
    if headers.present?
      headers[:to] = utf8_encode(headers[:to])
      headers[:subject] = "#{Setting[:email_subject_prefix]} #{headers[:subject]}" if (headers[:subject] && Setting[:email_subject_prefix].present?)
      headers['X-Foreman-Server'] = URI.parse(Setting[:foreman_url]).host if Setting[:foreman_url].present?
    end
    super
  end

  def default_url_options
    set_url
    {:host => @url.host, :port => @url.port, :protocol => @url.scheme}
  end

  protected

  def roadie_options
    url = URI.parse(Setting[:foreman_url])
    super.merge(url_options: {:host => url.host, :port => url.port, :protocol => url.scheme})
  end

  private

  def set_locale_for(user)
    old_loc = FastGettext.locale
    begin
      FastGettext.set_locale(user.locale.presence || 'en')
      yield if block_given?
    ensure
      FastGettext.locale = old_loc if block_given?
    end
  end

  def set_url
    unless (@url ||= URI.parse(Setting[:foreman_url])).present?
      raise Foreman::Exception.new(N_(":foreman_url is not set, please configure in the Foreman Web UI (Administer -> Settings -> General)"))
    end
  end

  # splitting the email address into two parts: local and domain parts.
  # each part needs to be encoded separately, for supporting utf-8 address encoding (RFC 6532)
  def utf8_encode(email)
    if email.present?
      address = email.split("@")
      (address.count == 2) ? Mail::Encodings.decode_encode(address[0], :encode) + '@' + Mail::Encodings.decode_encode(address[1], :encode) : email
    end
  end

  def set_delivery_options
    mail.delivery_method.settings.merge!(Setting::Email.delivery_settings.symbolize_keys)
  end
end
