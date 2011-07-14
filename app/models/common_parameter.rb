class CommonParameter < Parameter
  acts_as_audited :except => [:priority]
  validates_uniqueness_of :name

  def as_json(options={})
    super({:only => [:name, :value, :id]}.merge(options))
  end

end
