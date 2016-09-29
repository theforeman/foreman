class UserMailer < ApplicationMailer
  helper :reports

  def welcome(options = {})
    user = options[:user]
    @login = user.login

    set_locale_for(user) do
      mail(:to => user.mail, :subject => _("Welcome to Foreman"))
    end
  end

  def tester(options = {})
    user = options[:user]

    set_locale_for(user) do
      mail(:to => options[:email], :subject => _("Foreman test email")) do |format|
        format.html { render :layout => 'application_mailer' }
        format.text
      end
    end
  end
end
