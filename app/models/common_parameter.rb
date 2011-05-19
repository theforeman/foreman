class CommonParameter < Parameter
  validates_uniqueness_of :name

  def as_json(options={})
    super({:only => [:name, :value, :id]}.merge(options))
  end

end
