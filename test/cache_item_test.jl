using LFUDACache
using LFUDACache: CacheItem
using Test

@testset "Testing CacheItem initialization" begin
  value = Int(10)

  item = CacheItem{Int}(value, sizeof(value))

  @test item.data == value
  @test item.priority_key == 0
  @test item.frequency == 0
end

@testset "Testing CacheItem order" begin
  item_1 = CacheItem{Int}(10, sizeof(Int))
  item_1.priority_key = 1

  item_2 = CacheItem{Int}(1, sizeof(Int))
  item_2.priority_key = 10

  @test isless(item_1, item_2)
end

@testset "Testing cache priority policies" begin
  value = Int32(10)
  age = 2.5

  cache_item = CacheItem{Int32}(value, sizeof(Int32))
  cache_item.frequency = 10

  @test LFUDACache.lfu_priority_key_policy(cache_item, age) == 10.0
  @test LFUDACache.lfuda_priority_key_policy(cache_item, age) == 12.5
  @test LFUDACache.gdsf_priority_key_policy(cache_item, age) == 5.0
end
