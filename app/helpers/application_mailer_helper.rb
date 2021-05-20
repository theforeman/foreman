module ApplicationMailerHelper
  def email_footer
    uuid = Setting[:instance_id]
    title = Setting[:instance_title]

    if uuid.present? && title.present?
      _('This email was sent from Foreman instance %{title} identified by %{uuid}') % {title: title, uuid: uuid}
    elsif uuid.present?
      _('This email was sent from Foreman identified by UUID %{uuid}') % { uuid: uuid }
    end
  end
end
