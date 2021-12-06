module AuthorizerCache
  def initialize_cache
    @cache = HashWithIndifferentAccess.new do |h, k|
      h[k] = HashWithIndifferentAccess.new
    end
  end

  def collection_cache_lookup(subject, permission)
    collection = @cache[subject.class.to_s][permission] ||=
      find_collection(subject.class, :permission => permission).pluck(:id)

    collection.include?(subject.id)
  end
end
