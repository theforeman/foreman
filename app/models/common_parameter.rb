class CommonParameter < Parameter
  validates_uniqueness_of :name
end
