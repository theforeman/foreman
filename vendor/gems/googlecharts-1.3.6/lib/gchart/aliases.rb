class Gchart
  
  alias_method :background=, :bg=
  alias_method :chart_bg=, :graph_bg=
  alias_method :chart_color=, :graph_bg=
  alias_method :chart_background=, :graph_bg=
  alias_method :bar_color=, :bar_colors=
  alias_method :line_colors=, :bar_colors=
  alias_method :line_color=, :bar_colors=
  alias_method :labels=, :legend=
  alias_method :horizontal?, :horizontal
  alias_method :grouped?, :grouped

end