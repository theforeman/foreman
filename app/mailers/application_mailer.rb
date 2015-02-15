class ApplicationMailer < ActionMailer::Base
  default :from => Setting[:email_reply_address] || "noreply@foreman.example.org"

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
          Rails.logger.info("Unable to send mail notification: #{e}")
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
end
