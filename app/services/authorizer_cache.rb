module AuthorizerCache
  def initialize_cache
    @cache = Hash.new do |h, k|
      h[k] = {}
    end
  end

  def collection_cache_lookup(subject, permission)
    collection = @cache[subject.class.to_s][permission.to_s] ||=
      find_collection(subject.class, :permission => permission).pluck(:id)

    collection.include?(subject.id)
  end
end
