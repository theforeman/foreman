class UserMailer < ActionMailer::Base

  default :content_type => "text/plain", :from => Setting[:email_reply_address] || "noreply@foreman.example.org"

  def welcome(options = {})
    @user     = options[:user].login

    mail(:to      => options[:user].mail,
         :subject => _("Welcome to Foreman"),
         :date    => Time.now)
  end
end
