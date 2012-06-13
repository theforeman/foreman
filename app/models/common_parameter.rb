class CommonParameter < Parameter
  audited :except => [:priority]
  validates_uniqueness_of :name

  scoped_search :on => :name, :complete_value => :true
  scoped_search :on => :value, :complete_value => :true

  def as_json(options={})
    super({:only => [:name, :value, :id]}.merge(options))
  end

end
