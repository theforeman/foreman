require 'uri'

class ApplicationMailer < ActionMailer::Base
  include Roadie::Rails::Automatic
  default :from => Proc.new { Setting[:email_reply_address] || "noreply@foreman.example.org" }

  def mail(headers = {}, &block)
    if headers.present?
      headers[:subject] = "#{Setting[:email_subject_prefix]} #{headers[:subject]}" if (headers[:subject] && !Setting[:email_subject_prefix].blank?)
      headers['X-Foreman-Server'] = URI.parse(Setting[:foreman_url]).host unless Setting[:foreman_url].blank?
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
      FastGettext.set_locale(user.locale.blank? ? 'en' : user.locale)
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
end
