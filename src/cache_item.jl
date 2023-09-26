mutable struct CacheItem{V}
  priority_key::Float64
  frequency::Int
  data::V

  function CacheItem{V}(data::V) where {V}
    new{V}(
      0,
      0,
      data
    )
  end
end

struct CacheHeapNode{K,V}
  key::K
  cache_item::CacheItem{V}
end

function Base.isless(a::CacheItem{V}, b::CacheItem{V}) where {V}
  a.priority_key < b.priority_key
end

function Base.show(io::IO, cache_item::CacheItem)
  print(io, "CacheItem(Priority key: $(cache_item.priority_key), frequency: $(cache_item.frequency)")
end

function Base.isless(a::CacheHeapNode{K,V}, b::CacheHeapNode{K,V}) where {K,V}
  isless(a.cache_item, b.cache_item)
end

lfu_priority_key_policy(cache_item::CacheItem, ::Float64)::Float64 = cache_item.frequency
lfuda_priority_key_policy(cache_item::CacheItem, age::Float64)::Float64 = cache_item.frequency + age
