class UserMailer < ApplicationMailer
  helper :reports

  def welcome(options = {})
    user = options[:user]
    @login = user.login

    set_locale_for(user) do
      mail(:to => user.mail, :subject => _("Welcome to Foreman"))
    end
  end
end
