module UsersHelper
  def last_login_on_column(record)
    _("%s ago") % time_ago_in_words(record.last_login_on) if record.last_login_on
  end

  def auth_source_column(record)
    record.auth_source&.to_label
  end

  def contracted_host_list(user)
    content_tag(:span, :id => "contracted_host_list", :style => "display:inline;") do
      content_tag(:span, user.hosts.to_sentence)
    end
  end

  def expanded_host_list(user)
    content_tag(:span, :id => "expanded_host_list", :style => "display:none;") do
    end
  end

  def user_taxonomies_html_options(user)
    unless user.admin?
      {
        :location     => { :onchange => 'tfm.users.taxonomyAdded(this, "location")'},
        :organization => { :onchange => 'tfm.users.taxonomyAdded(this, "organization")'},
      }
    end
  end

  def user_action_buttons(user, additional_actions = [])
    if User.current.admin? && user != User.current && session[:impersonated_by].blank? && !user.disabled?
      additional_actions << link_to(_('Impersonate'),
        { :controller => 'users',
          :action => 'impersonate',
          :id => user.id,
        },
        :method => :post,
        :data => { :no_turbolink => true })
    end

    delete_btn = display_delete_if_authorized(
      hash_for_user_path(:id => user).merge(:auth_object => user, :authorizer => authorizer),
      :data => { :confirm => _("Delete %s?") % user.name })

    action_buttons(*([display_delete_unless_impersonator(delete_btn, user)] + additional_actions))
  end

  def display_delete_unless_impersonator(link, user)
    (user.id == session[:impersonated_by]) ? "" : link
  end

  def mail_notification_query_builder(mail_notification, f)
    render :partial => "#{mail_notification}_query_builder", :locals => {:f => f, :mailer => mail_notification.name } if mail_notification.queryable?
  end
end
