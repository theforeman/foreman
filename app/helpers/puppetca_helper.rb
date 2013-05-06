module PuppetcaHelper
  def state_filter
    select_tag "Filter", options_for_select(["", "revoked", "pending", "valid"], params[:state]),
               :onchange => "window.location.href = '#{smart_proxy_puppetca_index_path(@proxy)}' + (this.value == '' ? '' : ('?state=' + this.value))"
  end

  def time_column time, opts = {}
    return _("N/A") if time.blank?
    opts[:tense] ||= :past

    if opts[:tense] == :future
      _("in %s") % (time_ago_in_words time)
    elsif opts[:tense] == :past
      _("%s ago") % (time_ago_in_words time)
    else
      time_ago_in_words time
    end
  end

end
