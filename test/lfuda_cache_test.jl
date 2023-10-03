using LFUDACache
using LFUDACache: CacheItem
using DataStructures
using Test

@testset "Testing LFUDA initialization" begin
  lfuda = LFUDA{Symbol, Int32}(maxsize = 10)

  @test lfuda.age == 0
  @test lfuda.current_size == 0
  @test lfuda.maxsize == 10
end

@testset "Testing setting cache" begin
  key = :key
  value = Int32(5)

  @testset "Testing Base.setindex!" begin
    lfuda = LFUDA{Symbol, Int32}(maxsize = 10)

    @testset "Testing set new value" begin
      init_size = lfuda.current_size
      lfuda[key] = value

      @test haskey(lfuda.cache, key)
      @test lfuda.current_size == init_size + 1
      
      node_index, cache_item = lfuda.cache[key]

      @test cache_item.frequency == 1
      @test cache_item.priority_key === lfuda.priority_key_policy(cache_item, lfuda.age)
      @test cache_item.data == value

      cache_heap_node, handle = top_with_handle(lfuda.heap)

      @test handle == node_index
      @test cache_heap_node.key == key
      @test cache_heap_node.cache_item == cache_item
    end

    @testset "Testing replace old value" begin
      new_value = Int32(1)

      init_size = lfuda.current_size
      lfuda[key] = new_value

      @test haskey(lfuda.cache, key)
      @test lfuda.current_size == init_size

      node_index, cache_item = lfuda.cache[key]

      @test cache_item.frequency == 1
      @test cache_item.priority_key === lfuda.priority_key_policy(cache_item, lfuda.age)
      @test cache_item.data == new_value
    end
  end

  @testset "Testing Base.get!" begin
    lfuda = LFUDA{Symbol, Int32}(maxsize = 10)

    init_size = lfuda.current_size

    get!(lfuda, key, value, size=sizeof(Int))

    @test haskey(lfuda.cache, key)
    @test lfuda.current_size == init_size + 1
    
    node_index, cache_item = lfuda.cache[key]

    @test cache_item.frequency == 1
    @test cache_item.priority_key === lfuda.priority_key_policy(cache_item, lfuda.age)
    @test cache_item.data == value
  end

  @testset "Testing with limit" begin
    lfuda = LFUDA{Symbol, Int}(maxsize = 3)

    lfuda[:key_1] = 1
    # Access element to increase its frequency
    lfuda[:key_1]

    setindex!(lfuda, 2, :key_2, size=sizeof(Int))

    lfuda[:key_3] = 3
    lfuda[:key_3]

    lfuda[:key_4] = 4

    @test lfuda.current_size == 3
    @test length(lfuda.heap) == 3
    @test length(lfuda.cache) == 3
    @test !haskey(lfuda, :key_2)
    @test lfuda.age == 1
  end
end

@testset "Testing getting value" begin
  lfuda = LFUDA{Symbol, Int32}(maxsize = 10)

  value = Int32(10)
  default_value = Int32(5)

  lfuda[:key] = value
  node_index, cache_item = lfuda.cache[:key]
  init_freq = cache_item.frequency

  @testset "Testing Base.haskey" begin
    @test haskey(lfuda, :key)
    @test !haskey(lfuda, :key_2)
  end

  @testset "Testing Base.getindex" begin
    @test lfuda[:key] == value
    @test cache_item.frequency == init_freq + 1

    @test_throws KeyError(:key_2) lfuda[:key_2]
  end

  @testset "Testing Base.get" begin
    @test get(lfuda, :key, default_value) == value
    @test cache_item.frequency == init_freq + 2

    @test get(() -> default_value, lfuda, :key) == value
    @test cache_item.frequency == init_freq + 3

    @test get(lfuda, :key_2, default_value) == default_value
    @test get(() -> default_value, lfuda, :key_2) == default_value
  end

  @testset "Testing Base.get!" begin
    @test get!(lfuda, :key, default_value) == value
    @test cache_item.frequency == init_freq + 4

    @test get!(() -> default_value, lfuda, :key) == value
    @test cache_item.frequency == init_freq + 5

    @test get!(lfuda, :key_4, default_value) == default_value
    @test get!(() -> default_value, lfuda, :key_5) == default_value
  end
end

@testset "Testing deletion" begin
  lfuda = LFUDA{Symbol, Int32}(maxsize = 10)

  value = Int32(10)
  default_value = Int32(5)

  lfuda[:key] = value
  node_index, cache_item = lfuda.cache[:key]

  init_size = lfuda.current_size
  init_heap_size = length(lfuda.heap)

  delete!(lfuda, :key)

  @test lfuda.current_size == init_size - 1
  @test !haskey(lfuda, :key)
  @test length(lfuda.heap) == init_heap_size - 1
end
