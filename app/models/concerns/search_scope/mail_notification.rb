module SearchScope
  module MailNotification
    extend ActiveSupport::Concern

    included do
      scoped_search :on => :name, :complete_value => true
      scoped_search :on => :description, :complete_value => true
      scoped_search :in => :users, :on => :login, :complete_value => true, :rename => :user
    end
  end
end
