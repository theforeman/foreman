class ReportTemplate < Template
  audited

  include Authorizable
  extend FriendlyId
  friendly_id :name
  include Parameterizable::ByIdName

  class << self
    # we have to override the base_class because polymorphic associations does not detect it correctly, more details at
    # http://apidock.com/rails/ActiveRecord/Associations/ClassMethods/has_many#1010-Polymorphic-has-many-within-inherited-class-gotcha
    def base_class
      self
    end
  end
  self.table_name = 'templates'

  validates :name, :uniqueness => true

  include Taxonomix
  scoped_search :on => :id, :complete_enabled => false, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
  scoped_search :on => :name,    :complete_value => true, :default_order => true
  scoped_search :on => :locked,  :complete_value => {:true => true, :false => false}
  scoped_search :on => :snippet, :complete_value => {:true => true, :false => false}
  scoped_search :on => :template
  scoped_search :on => :default, :only_explicit => true, :complete_value => {:true => true, :false => false}

  # with proc support, default_scope can no longer be chained
  # include all default scoping here
  default_scope lambda {
    with_taxonomy_scope do
      order("#{Template.table_name}.name")
    end
  }

  def self.default_render_scope_class
    Foreman::Renderer::Scope::Report
  end

  def taxonomy_foreign_conditions
    { :report_template_id => id }
  end

  def suggested_report_name
    "#{name}-#{Date.today}"
  end

  def self.acceptable_template_input_types
    [:user]
  end

  # we don't want to log reports, it can be a lot of data
  def self.log_render_results?
    false
  end

  def supports_format_selection?
    template.include?('report_render')
  end

  def support_single_host_render?
    false
  end
end
