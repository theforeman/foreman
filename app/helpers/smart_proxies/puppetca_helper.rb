module SmartProxies::PuppetcaHelper
  def state_filter
    select_tag "Filter", options_for_select(["default (valid + pending)", "all", "revoked", "pending", "valid"],
               :onchange => "window.location.href = '#{smart_proxy_puppetca_index_path(@proxy)}' + (this.value == '' ? '' : ('?state=' + this.value))"
  end

  def time_column time, opts = {}
    return "N/A" if time.blank?
    opts[:tense] ||= :past
    str = ""
    str = "in " if opts[:tense] == :future
    str += time_ago_in_words time
    str += " ago" if opts[:tense] == :past
    str
  end

end
