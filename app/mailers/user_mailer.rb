class UserMailer < ApplicationMailer
  helper :reports

  def welcome(options = {})
    user = User.find(options[:user])
    @login = user.login

    set_locale_for user

    mail(:to      => user.mail,
         :subject => _("Welcome to Foreman"),
         :date    => Time.now)
  end
end
