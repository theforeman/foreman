require 'uri'

class ApplicationMailer < ActionMailer::Base
  default :from => Setting[:email_reply_address] || "noreply@foreman.example.org"

  def mail(headers = {}, &block)
    if headers.present?
      headers[:subject] = "#{Setting[:email_subject_prefix]} #{headers[:subject]}" if (headers[:subject] && !Setting[:email_subject_prefix].blank?)
      headers['X-Foreman-Server'] = URI.parse(Setting[:foreman_url]).host unless Setting[:foreman_url].blank?
    end
    super
  end

  private

  class GroupMail
    def initialize(emails)
      @emails = emails
    end

    def deliver
      @emails.each do |email|
        begin
          email.deliver
        rescue => e
          Rails.logger.info("Unable to send email notification: #{e}")
        end
      end
    end
  end

  def group_mail(users, options)
    mails = users.map do |user|
      @user = user
      set_locale_for user
      mail(options.merge(:to => user.mail)) unless user.mail.blank?
    end

    GroupMail.new(mails.compact)
  end

  def set_locale_for(user)
    FastGettext.set_locale(user.locale.blank? ? "en" : user.locale)
  end

  def set_url
    unless (@url = URI.parse(Setting[:foreman_url])).present?
      raise Foreman::Exception.new(N_(":foreman_url is not set, please configure in the Foreman Web UI (Administer -> Settings -> General)"))
    end
  end
end
