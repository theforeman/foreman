module SearchScope
  module Report
    extend ActiveSupport::Concern

    included do
      scoped_search :in => :host,        :on => :name,  :complete_value => true, :rename => :host
      scoped_search :in => :environment, :on => :name,  :complete_value => true, :rename => :environment
      scoped_search :in => :messages,    :on => :value,                          :rename => :log
      scoped_search :in => :sources,     :on => :value,                          :rename => :resource
      scoped_search :in => :hostgroup,   :on => :name,  :complete_value => true, :rename => :hostgroup
      scoped_search :in => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_fullname
      scoped_search :in => :hostgroup,   :on => :title, :complete_value => true, :rename => :hostgroup_title

      scoped_search :on => :reported_at, :complete_value => true, :default_order => :desc,    :rename => :reported, :only_explicit => true
      scoped_search :on => :status, :offset => 0, :word_size => 4 * self::BIT_NUM, :complete_value => {:true => true, :false => false}, :rename => :eventful

      scoped_search :on => :status, :offset => self::METRIC.index("applied"),         :word_size => self::BIT_NUM, :rename => :applied
      scoped_search :on => :status, :offset => self::METRIC.index("restarted"),       :word_size => self::BIT_NUM, :rename => :restarted
      scoped_search :on => :status, :offset => self::METRIC.index("failed"),          :word_size => self::BIT_NUM, :rename => :failed
      scoped_search :on => :status, :offset => self::METRIC.index("failed_restarts"), :word_size => self::BIT_NUM, :rename => :failed_restarts
      scoped_search :on => :status, :offset => self::METRIC.index("skipped"),         :word_size => self::BIT_NUM, :rename => :skipped
      scoped_search :on => :status, :offset => self::METRIC.index("pending"),         :word_size => self::BIT_NUM, :rename => :pending
    end
  end
end
